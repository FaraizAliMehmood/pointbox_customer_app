import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/reviews/controllers/reviews_controller.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';
import 'package:pointbox_mobile/app/widgets/gradient_app_bar.dart';

class ReviewsView extends GetView<ReviewsController> {
  const ReviewsView({super.key});

  void _showToast(String message, bool isSuccess) {
    try {
      // Use post frame callback to ensure UI is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            Get.snackbar(
              isSuccess ? 'Success' : 'Error',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              colorText: Colors.white,
              duration: Duration(seconds: isSuccess ? 3 : 2),
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              isDismissible: true,
              dismissDirection: DismissDirection.horizontal,
              instantInit: false, // Prevent initialization errors
            );
          } catch (e) {
            print('Error showing snackbar: $e');
          }
        });
      });
    } catch (e) {
      print('Error in _showToast: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: GradientAppBar(title: 'write_a_review'.tr),
        backgroundColor: const Color(0xFFF3E8FF), // Light purple background
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                   Color(0xFFE9D5FF), // Lighter purple at top
                   Color(0xFFF3E8FF), // Light purple in middle
                   Color(0xFFE9D5FF), // Lighter purple at bottom
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Darker purple edges
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xFF9333EA).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          const Color(0xFF9333EA).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with icon and title
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF9333EA), // purple-600
                                        Color(0xFF4F46E5), // indigo-800
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.star_outline,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Share Your Experience',
                                  style: ThemeService.outfit(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Rating Section
                            Text(
                              'Rating *',
                              style: ThemeService.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  final starIndex = index + 1;
                                  final isSelected = starIndex <= controller.rating.value;
                                  return GestureDetector(
                                    onTap: () => controller.setRating(starIndex),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(
                                        isSelected ? Icons.star : Icons.star_border,
                                        color: isSelected
                                            ? const Color(0xFFFFD700) // Gold for selected
                                            : Colors.grey[400],
                                        size: 48,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(
                              () => Center(
                                child: Text(
                                  controller.rating.value == 0
                                      ? 'Tap to rate'
                                      : '${controller.rating.value} ${controller.rating.value == 1 ? 'star' : 'stars'}',
                                  style: ThemeService.outfit(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Review Text Field
                            Text(
                              'Your Review *',
                              style: ThemeService.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller.reviewController,
                              maxLines: 8,
                              decoration: InputDecoration(
                                hintText: 'Tell us about your experience with the app...',
                                hintStyle: ThemeService.outfit(
                                  color: Colors.grey[500],
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF9333EA),
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: ThemeService.outfit(
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Submit Button
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () async {
                                          // Validate first in view
                                          if (controller.rating.value == 0) {
                                            _showToast('Please select a rating', false);
                                            return;
                                          }
                                          if (controller.reviewController.text.trim().isEmpty) {
                                            _showToast('Please enter your review', false);
                                            return;
                                          }
                                          
                                          // Call controller method (it will show snackbar on success/error)
                                          await controller.submitReview();
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF9333EA),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Submit Review',
                                          style: ThemeService.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Info text
                            Center(
                              child: Text(
                                'Your feedback helps us improve!',
                                style: ThemeService.outfit(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
