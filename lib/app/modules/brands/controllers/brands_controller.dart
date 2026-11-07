import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';

class BrandsController extends GetxController {
  final brands = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final filterType = 'all'.obs; // 'all', 'linked', 'unlinked'
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _updateNavigationIndex();
    loadBrands();
  }

  void _updateNavigationIndex() {
    // Defer to after the current frame: calling this synchronously during
    // onInit() can run while another widget (e.g. HomeView's BottomNavBar,
    // still mounted during the route transition) is mid-build, which throws
    // "setState() or markNeedsBuild() called during build".
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.currentIndex.value = 1;
      }
    });
  }

  /// Clear any in-memory linked state; real-time data comes from API next load
  Future<void> clearLinkedBrandsCache() async {
    for (var brand in brands) {
      brand['linked'] = false;
    }
  }

  // Fetch linked brands from API and store in _saveLinkedBrands
  Future<void> fetchLinkedBrands() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Use customer profile (same as web) to determine linked brands
      final linkedBrandIds = await _getLinkedBrandIdsFromProfile();
        
      if (linkedBrandIds.isEmpty) {
        error.value = 'Failed to fetch linked brands';
        return;
      }

      // Update local brands state to reflect linked status
      for (var brand in brands) {
        brand['linked'] = linkedBrandIds.contains(brand['id']);
      }
    } catch (e) {
      print('Error fetching linked brands: $e');
      error.value = e.toString().replaceFirst('Exception: ', 'Failed to fetch linked brands');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBrands() async {
    isLoading.value = true;
    error.value = '';
    try {
      // Fetch all brands
      final brandsResponse = await ApiService.getBrands();
      print("Brands: $brandsResponse");
      
      if (brandsResponse['success'] == true && brandsResponse['data'] != null) {
        final List<dynamic> brandsData = brandsResponse['data'];
        
        // Fetch linked brands from customer profile (same as web)
        final linkedBrandIds = await _getLinkedBrandIdsFromProfile();
        
        // Map API response to component's Brand interface (matching web version)
        brands.value = brandsData.map((brand) {
          final brandId = (brand['id'] ?? brand['_id'] ?? '').toString();
          return {
            'id': brandId,
            'name': brand['companyName'] ?? '',
            'description': brand['address'] ?? brand['country'] ?? 'Partner brand',
            'logo': brand['logo'] ?? brand['companyLogo'] ?? '',
            'companyLogo': brand['companyLogo'] ?? brand['logo'] ?? '',
            // explicit country field for UI
            'country': brand['country'] ?? '',
            'category': brand['country'] ?? 'General',
            'linked': linkedBrandIds.contains(brandId),
          };
        }).toList();
      } else {
        error.value = brandsResponse['message'] ?? 'Failed to load brands';
      }
    } catch (e) {
      print('Error fetching brands: $e');
      error.value = e.toString().replaceFirst('Exception: ', 'Failed to load brands');
      // Don't show snackbar during initialization - error state will be shown in UI
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the list of linked brand IDs for the current customer from their profile.
  /// Mirrors the web app, which uses `user.linkedBrands` from auth context.
  Future<List<String>> _getLinkedBrandIdsFromProfile() async {
    try {
      final profileResponse = await ApiService.getProfile();
      print("Profile (for linked brands): ${const JsonEncoder.withIndent('  ').convert(profileResponse)}");

      if (profileResponse['success'] != true || profileResponse['data'] == null) {
        return [];
      }

      final data = profileResponse['data'];
      final customer = data['customer'] ?? data['user'] ?? data;
      final rawLinked = customer['linkedBrands'];

      if (rawLinked is List) {
        return rawLinked
            .map((item) {
              if (item is Map) {
                return item['_id']?.toString() ?? item['id']?.toString() ?? '';
              } else if (item is String) {
                return item;
              }
              return '';
            })
            .where((id) => id.isNotEmpty)
            .toList();
      }

      return [];
    } catch (e) {
      print('Error reading linked brands from profile: $e');
      return [];
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Map<String, dynamic>> get filteredBrands {
    var filtered = List<Map<String, dynamic>>.from(brands);

    // Filter by linked status
    if (filterType.value == 'linked') {
      filtered = filtered.where((brand) => brand['linked'] == true).toList();
    } else if (filterType.value == 'unlinked') {
      filtered = filtered.where((brand) => brand['linked'] == false).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((brand) {
        final queryLower = searchQuery.value.toLowerCase();
        return (brand['name']?.toString().toLowerCase().contains(queryLower) ?? false) ||
            (brand['description']?.toString().toLowerCase().contains(queryLower) ?? false) ||
            (brand['category']?.toString().toLowerCase().contains(queryLower) ?? false);
      }).toList();
    }

    return filtered;
  }

  void setFilterType(String type) {
    filterType.value = type;
  }

  Future<void> linkBrand(String brandId) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      print("Brand ID is: $brandId");
      final response = await ApiService.post(
        '/link-brand',
        {'brandId': brandId},
        requiresAuth: true,
      );
      
      // Pretty print the response model
      print("Response Model:");
      print(const JsonEncoder.withIndent('  ').convert(response));
      
      if (response['success'] == true && response['data'] != null) {
        final responseData = response['data'];
        
        // Update linked brands from API response (real-time)
        if (responseData['linkedBrands'] != null) {
          final linkedBrandsList = List<String>.from(
            (responseData['linkedBrands'] as List).map((e) => e.toString())
          );
          for (var brand in brands) {
            brand['linked'] = linkedBrandsList.contains(brand['id']);
          }
        }
        
        // Update HomeController's totalPoints from real-time API response, if available
        int? apiPoints;
        if (responseData['customer'] != null) {
          final rawPoints = responseData['customer']['totalPoints'] ?? responseData['customer']['points'];
          if (rawPoints != null) {
            apiPoints = rawPoints is int ? rawPoints : int.tryParse(rawPoints.toString());
          }
        }

        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          if (apiPoints != null) {
            homeController.totalPoints.value = apiPoints;
          }
        }
        // Ensure the tapped brand is marked linked even if API didn't return list
        final index = brands.indexWhere((b) => b['id'] == brandId);
        if (index != -1) {
          brands[index]['linked'] = true;
        }
        
        _showSnackbar(
          'success'.tr,
          'Brand linked successfully',
          backgroundColor: Colors.green,
        );
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      error.value = e.toString();
      _showSnackbar(
        'error'.tr,
       error.value,
        backgroundColor: Get.theme.colorScheme.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message, {required Color backgroundColor}) {
    // Schedule snackbar after the current frame to ensure overlay is ready
    // Also check if context has overlay before showing snackbar
    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        // Check if overlay is available
        if (Get.context != null) {
          try {
            Overlay.of(Get.context!);
            Get.snackbar(
              title,
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: backgroundColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          } catch (e) {
            // Overlay not available - just log the message
            print('Snackbar unavailable (no overlay): $title - $message');
          }
        }
      } catch (e) {
        // Handle overlay exception gracefully - just log it
        print('Snackbar unavailable: $title - $message');
        print('Error: $e');
      }
    });
  }
}

