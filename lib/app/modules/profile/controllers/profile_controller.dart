import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  static const int minAge = 13;

  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final dateOfBirth = ''.obs;
  final dateOfBirthDate = Rx<DateTime?>(null);
  final totalPoints = 0.obs;
  final isLoading = false.obs;
  final isUpdatingDateOfBirth = false.obs;
  final customerId = ''.obs;

  final linkedBrands = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Defer async operations and navigation updates to after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationIndex();
      loadProfile();
    });
  }

  void _updateNavigationIndex() {
    // Only update navigation index if we're actually on the Profile route
    // Don't update if we're on QR_CODE route (which also uses ProfileBinding)
    if (Get.isRegistered<HomeController>() && Get.currentRoute == AppRoutes.PROFILE) {
      final homeController = Get.find<HomeController>();
      homeController.currentIndex.value = 4;
    }
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final response = await ApiService.getProfile();
      print("Profile Response: $response");
      if (response['success'] == true && response['data'] != null) {
        final profileData = response['data'] as Map<String, dynamic>;
        
        // Extract customer ID
        if (profileData['id'] != null) {
          customerId.value = profileData['id'].toString();
        }
        
        // Update profile fields from API response
        if (profileData['username'] != null) {
          userName.value = profileData['username'].toString();
        }
        if (profileData['email'] != null) {
          userEmail.value = profileData['email'].toString();
        }
        if (profileData['phone'] != null) {
          userPhone.value = profileData['phone'].toString();
        }
        dateOfBirth.value = _formatDateOfBirth(profileData['dateOfBirth']);
        dateOfBirthDate.value = profileData['dateOfBirth'] != null
            ? DateTime.tryParse(profileData['dateOfBirth'].toString())
            : null;
        if (profileData['totalPoints'] != null) {
          final points = profileData['totalPoints'];
          totalPoints.value = points is int ? points : int.tryParse(points.toString()) ?? 0;
        }
        
        // Load linked companies from profile response
        if (profileData['linkedCompanies'] != null && profileData['linkedCompanies'] is List) {
          final List<dynamic> linkedCompanies = profileData['linkedCompanies'];
          // Map linkedCompanies to linkedBrands format expected by UI
          linkedBrands.value = linkedCompanies.map((company) {
            final companyData = company as Map<String, dynamic>;
            // Map the data structure to match what the UI expects
            return {
              'company': companyData['company'],
              'companyName': companyData['companyName'] ?? '',
              'companyLogo': companyData['companyLogo'] ?? '',
              'points': companyData['redeem_points'] ?? 0,
              'redeem_points': companyData['redeem_points'] ?? 0,
              'tier_points': companyData['tier_points'] ?? 0,
              'linkedAt': companyData['linkedAt'],
              'tier': companyData['tier'],
            };
          }).toList().cast<Map<String, dynamic>>();
        } else {
          linkedBrands.value = [];
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      // On error, set empty values
      userName.value = '';
      userEmail.value = '';
      userPhone.value = '';
      dateOfBirth.value = '';
      totalPoints.value = 0;
      linkedBrands.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Format a date-of-birth string, or "-" when it's missing/invalid
  String _formatDateOfBirth(dynamic dateOfBirth) {
    if (dateOfBirth == null) return '-';
    final parsed = DateTime.tryParse(dateOfBirth.toString());
    if (parsed == null) return '-';
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  int _ageFromDateOfBirth(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> pickAndUpdateDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirthDate.value ??
          DateTime(now.year - minAge, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: DateTime(now.year - minAge, now.month, now.day),
    );

    if (picked == null) return;

    if (_ageFromDateOfBirth(picked) < minAge) {
      Get.snackbar(
        'error'.tr,
        'You must be at least $minAge years old',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    isUpdatingDateOfBirth.value = true;
    try {
      final isoDate = picked.toIso8601String().split('T').first;
      final response = await ApiService.updateProfile(dateOfBirth: isoDate);

      if (response['success'] == true) {
        dateOfBirthDate.value = picked;
        dateOfBirth.value = _formatDateOfBirth(isoDate);
        Get.snackbar(
          'success'.tr,
          'Date of birth updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorMsg = response['message'] ?? 'Failed to update date of birth';
        Get.snackbar(
          'error'.tr,
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingDateOfBirth.value = false;
    }
  }

  void showQRCode() {
    Get.toNamed(AppRoutes.QR_CODE);
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('are_you_sure'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.setBool('is_logged_in', false);
      await _storage.remove('auth_token');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  Future<void> deleteAccount() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('delete_account'.tr),
        content: Text('delete_account_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('delete_account'.tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      isLoading.value = true;
      try {
        await _storage.clear();
        Get.offAllNamed(AppRoutes.LOGIN);
      } finally {
        isLoading.value = false;
      }
    }
  }

  void changeLanguage() {
    final currentLocale = Get.locale;
    final newLocale = currentLocale?.languageCode == 'ar'
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');
    Get.updateLocale(newLocale);
  }
}

