import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/auth/controllers/auth_controller.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: AppBar(
          title: Text('signup'.tr),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
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
                            'signup'.tr,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              labelText: 'name'.tr,
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'email'.tr,
                              prefixIcon: const Icon(Icons.email),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'phone'.tr,
                              prefixIcon: const Icon(Icons.phone),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => InkWell(
                              onTap: () => controller.pickDateOfBirth(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'date_of_birth'.tr,
                                  prefixIcon: const Icon(Icons.cake_outlined),
                                ),
                                child: Text(
                                  controller.selectedDateOfBirth.value != null
                                      ? '${controller.selectedDateOfBirth.value!.year}-${controller.selectedDateOfBirth.value!.month.toString().padLeft(2, '0')}-${controller.selectedDateOfBirth.value!.day.toString().padLeft(2, '0')}'
                                      : 'date_of_birth'.tr,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => TextField(
                              controller: controller.passwordController,
                              obscureText: !controller.isPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: 'password'.tr,
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: controller.togglePasswordVisibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => TextField(
                              controller: controller.confirmPasswordController,
                              obscureText: !controller.isConfirmPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: 'confirm_password'.tr,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: controller.toggleConfirmPasswordVisibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: controller.addressController,
                            decoration: InputDecoration(
                              labelText: 'address'.tr,
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: controller.selectedCountry.value.isEmpty
                                  ? null
                                  : controller.selectedCountry.value,
                              decoration: InputDecoration(
                                labelText: 'country'.tr,
                                prefixIcon: const Icon(Icons.public),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'UAE', child: Text('UAE')),
                                DropdownMenuItem(value: 'Saudi Arabia', child: Text('Saudi Arabia')),
                                DropdownMenuItem(value: 'Qatar', child: Text('Qatar')),
                                DropdownMenuItem(value: 'Kuwait', child: Text('Kuwait')),
                                DropdownMenuItem(value: 'Bahrain', child: Text('Bahrain')),
                                DropdownMenuItem(value: 'Oman', child: Text('Oman')),
                                DropdownMenuItem(value: 'Jordan', child: Text('Jordan')),
                                DropdownMenuItem(value: 'Lebanon', child: Text('Lebanon')),
                                DropdownMenuItem(value: 'Egypt', child: Text('Egypt')),
                                DropdownMenuItem(value: 'Iraq', child: Text('Iraq')),
                                DropdownMenuItem(value: 'Syria', child: Text('Syria')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedCountry.value = value;
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => Row(
                              children: [
                                Checkbox(
                                  value: controller.isTermsAccepted.value,
                                  onChanged: (value) {
                                    controller.isTermsAccepted.value = value ?? false;
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Show terms dialog when clicking on the text
                                      await controller.showTermsDialog();
                                    },
                                    child: Text(
                                      'terms_and_conditions'.tr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Obx(
                            () {
                              if (controller.signupError.value.isNotEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.signupError.value,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          Obx(
                            () {
                              final isEnabled = !controller.isLoading.value && controller.isTermsAccepted.value;
                              return ElevatedButton(
                                onPressed: isEnabled ? controller.signup : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isEnabled ? Colors.purple : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  disabledBackgroundColor: Colors.grey,
                                  disabledForegroundColor: Colors.white70,
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
                                    : Text('signup'.tr),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('already_have_account'.tr),
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('login'.tr),
                              ),
                            ],
                          ),
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

