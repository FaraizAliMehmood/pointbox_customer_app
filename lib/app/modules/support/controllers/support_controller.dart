import 'package:get/get.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';
import 'package:flutter/material.dart';

class SupportController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final selectedBrand = ''.obs;
  final brands = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingBrands = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBrands();
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> loadBrands() async {
    isLoadingBrands.value = true;
    try {
      final brandsResponse = await ApiService.getBrands();
      
      if (brandsResponse['success'] == true && brandsResponse['data'] != null) {
        final List<dynamic> brandsData = brandsResponse['data'];
        brands.value = brandsData.map((brand) {
          return {
            'id': (brand['id'] ?? brand['_id'] ?? '').toString(),
            'name': brand['companyName'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      print('Error loading brands: $e');
    } finally {
      isLoadingBrands.value = false;
    }
  }

  Future<void> sendEmail() async {
    if (selectedBrand.value.isEmpty ||
        subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService.contactSupport(
        brandId: selectedBrand.value,
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );

      if (response['success'] == true) {
        // Clear form on success
        subjectController.clear();
        messageController.clear();
        selectedBrand.value = '';
        
        Get.snackbar(
          'success'.tr,
          response['message'] ?? 'Support request sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to send support request');
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
      isLoading.value = false;
    }
  }

}

