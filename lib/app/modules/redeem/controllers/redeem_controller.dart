import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';

class RedeemController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final pointsController = TextEditingController();
  final searchController = TextEditingController();
  final availablePoints = 0.obs;
  final isLoading = false.obs;
  final isLoadingProducts = false.obs;
  final products = <Map<String, dynamic>>[].obs;
  final error = ''.obs;
  final searchQuery = ''.obs;

  // Filtered products based on search
  List<Map<String, dynamic>> get filteredProducts {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) {
      return products.toList();
    }
    return products.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final description = (product['description'] ?? '').toString().toLowerCase();
      final points = (product['redeem_points'] ?? 0).toString();

      // Backend sends `company` as a plain company id and `companyName` as a
      // flat string on the product - there is no nested company object.
      final companyName = (product['companyName'] ?? '').toString().toLowerCase();

      return name.contains(query) || 
             description.contains(query) || 
             points.contains(query) ||
             companyName.contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  @override
  void onInit() {
    super.onInit();
    _loadPoints();
    loadProducts();
  }

  @override
  void onClose() {
    pointsController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _loadPoints() {
    availablePoints.value = _storage.getInt('total_points') ?? 0;
  }

  Future<void> loadProducts() async {
    isLoadingProducts.value = true;
    error.value = '';
    try {
      final productsResponse = await ApiService.getProducts();
      
      if (productsResponse['success'] == true && productsResponse['data'] != null) {
        final List<dynamic> productsData = productsResponse['data'];
        products.value = productsData.cast<Map<String, dynamic>>();
        // products.value = productsData.map((product) {
        //   return {
        //     'id': product['_id'] ?? product['id'] ?? '',
        //     'name': product['name'] ?? product['productName'] ?? '',
        //     'description': product['description'] ?? '',
        //     'image': product['image'] ?? product['imageUrl'] ?? product['productImage'] ?? '',
        //     'points': product['redeem_points'] ?? 0,
        //     'category': product['category'] ?? '',
        //     'brand': product['brand'] ?? product['brandName'] ?? '',
        //     'couponCode': product['couponCode'] ?? product['code'] ?? product['coupon'] ?? '',
        //   };
        // }).toList();
      } else {
        error.value = productsResponse['message'] ?? 'Failed to load products';
      }
    } catch (e) {
      error.value = 'Error loading products: ${e.toString()}';
      print('Error loading products: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> redeemPoints() async {
    final points = int.tryParse(pointsController.text) ?? 0;

    if (points <= 0) {
      Get.snackbar(
        'error'.tr,
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    if (points > availablePoints.value) {
      Get.snackbar(
        'error'.tr,
        'Insufficient points',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final newPoints = availablePoints.value - points;
      await _storage.setInt('total_points', newPoints);
      availablePoints.value = newPoints;
      pointsController.clear();

      Get.snackbar(
        'success'.tr,
        'Points redeemed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Redemption failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

