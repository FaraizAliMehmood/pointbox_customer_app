import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:pointbox_mobile/app/modules/auth/controllers/auth_controller.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.purple),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.purple),
      borderRadius: BorderRadius.circular(12),
      color: Colors.purple.shade50,
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.red),
      borderRadius: BorderRadius.circular(12),
    );

    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('verify_otp'.tr),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: ThemeService.purpleGradient,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'verify_otp'.tr,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'otp_message'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Pinput(
                            length: 4,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            submittedPinTheme: submittedPinTheme,
                            errorPinTheme: errorPinTheme,
                            pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                            showCursor: true,
                            onCompleted: (pin) {
                              controller.otpCode.value = pin;
                              controller.verifyOtp(pin, context: context);
                            },
                            onChanged: (value) {
                              controller.otpCode.value = value;
                              controller.otpError.value = '';
                            },
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => controller.otpError.value.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      controller.otpError.value,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () {
                              // Access observables at the top level of Obx builder
                              final isLoading = controller.isLoading.value;
                              final otpCode = controller.otpCode.value;
                              
                              return ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (otpCode.length == 4) {
                                          controller.verifyOtp(otpCode, context: context);
                                        } else {
                                          Get.snackbar(
                                            'error'.tr,
                                            'please_enter_otp'.tr,
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Get.theme.colorScheme.error,
                                            colorText: Colors.white,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  fixedSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'verify'.tr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Obx(
                          //   () => TextButton(
                          //     onPressed: controller.isLoading.value ||
                          //             controller.resendTimer.value > 0
                          //         ? null
                          //         : controller.resendOtp,
                          //     child: Text(
                          //       controller.resendTimer.value > 0
                          //           ? 'resend_otp_in'.tr.replaceAll(
                          //               '{seconds}',
                          //               controller.resendTimer.value.toString(),
                          //             )
                          //           : 'resend_otp'.tr,
                          //     ),
                          //   ),
                         // ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

