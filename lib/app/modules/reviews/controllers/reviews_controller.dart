import 'package:get/get.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class ReviewsController extends GetxController {
  final reviewController = TextEditingController();
  final rating = 0.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  void setRating(int value) {
    rating.value = value;
  }

  Future<void> submitReview() async {
    isLoading.value = true;
    try {
      final response = await ApiService.submitReview(
        rating: rating.value,
        review: reviewController.text.trim(),
      );

      if (response['success'] == true) {
        // Clear form on success
        reviewController.clear();
        rating.value = 0;
        isLoading.value = false;
        
        // Show success snackbar before navigation
        // Wait a bit to ensure UI is ready, then show snackbar
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Show success snackbar using default Flutter snackbar
        if (Get.context != null) {
          try {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Thank you for your review!',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                dismissDirection: DismissDirection.horizontal,
              ),
            );
            
            // Wait for snackbar to display, then navigate
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (e) {
            // If snackbar fails, just navigate
            print('Error showing snackbar: $e');
          }
        }
        
        // Navigate back to home
        Get.offAllNamed(AppRoutes.HOME);
        return;
      } else {
        throw Exception(response['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      String errorMessage = 'Failed to submit review';
      
      if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('User ID not found')) {
        errorMessage = 'User ID not found. Please try logging out and back in.';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      
      // Wait a bit to ensure UI is ready, then show snackbar
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Show error snackbar using default Flutter snackbar
      if (Get.context != null) {
        try {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Get.theme.colorScheme.error,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              dismissDirection: DismissDirection.horizontal,
            ),
          );
        } catch (e) {
          print('Error showing snackbar: $e');
        }
      }
    } finally {
      if (isLoading.value) {
        isLoading.value = false;
      }
    }
  }
}
