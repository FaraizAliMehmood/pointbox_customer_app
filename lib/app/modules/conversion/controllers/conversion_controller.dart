import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversionController extends GetxController {
  final amountController = TextEditingController();
  final conversionRate = 3.25.obs; // KWD to USD rate (example)
  final convertedAmount = 0.0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchConversionRate();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> _fetchConversionRate() async {
    isLoading.value = true;
    try {
      // Simulate API call to fetch real-time rate
      await Future.delayed(const Duration(seconds: 1));
      // In real app, fetch from API
      conversionRate.value = 3.25;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to fetch conversion rate',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void convert() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      Get.snackbar(
        'error'.tr,
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
      return;
    }

    convertedAmount.value = amount * conversionRate.value;
  }
}

