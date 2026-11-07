import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/auth/controllers/auth_controller.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AuthController());

    return ResponsiveLayout(
      mobile: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: Container(
            decoration: ThemeService.purpleGradient,
            child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset('./assets/images/logo.png')),
              //       Image.network(
              //   'https://res.cloudinary.com/dcz9bugal/image/upload/v1765730094/settings-logos/yqfrzyjurn9kkvxrgde1.png',
              //   width: 200,
              //   height: 200,
              //   fit: BoxFit.contain,
              //   errorBuilder: (context, error, stackTrace) {
              //     return const Icon(
              //       Icons.image_not_supported,
              //       size: 200,
              //       color: Colors.white70,
              //     );
              //   },
              //   loadingBuilder: (context, child, loadingProgress) {
              //     if (loadingProgress == null) return child;
              //     return const SizedBox(
              //       width: 200,
              //       height: 200,
              //       child: Center(
              //         child: CircularProgressIndicator(
              //           color: Colors.white,
              //         ),
              //       ),
              //     );
              //   },
              // ),
                  const SizedBox(height: 16),
                  Text(
                    'app_name'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 48),
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
                            'login'.tr,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'email'.tr,
                              prefixIcon: const Icon(Icons.email),
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
                          const SizedBox(height: 24),
                          Obx(
                            () => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  : Text('login'.tr),
                            ),
                          ),
                          Obx(
                            () => controller.loginError.value.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      controller.loginError.value,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.CHECK_EMAIL);
                            },
                            child: Text('forgot_password'.tr),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('dont_have_account'.tr),
                              TextButton(
                                onPressed: () => Get.toNamed(AppRoutes.SIGNUP),
                                child: Text('signup'.tr),
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
      ),
    );
  }
}

