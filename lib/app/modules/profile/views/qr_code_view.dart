import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/profile/controllers/profile_controller.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/gradient_app_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeView extends StatelessWidget {
  const QRCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final storage = Get.find<StorageService>();
    final userEmail = storage.getString('user_email') ?? 'user@example.com';

    return Scaffold(
      appBar: GradientAppBar(title: 'my_qr_code'.tr),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Obx(
                    () {
                      // Use customer ID if available, otherwise fall back to email
                      final qrData = controller.customerId.value.isNotEmpty
                          ? '${controller.customerId.value}'
                          : 'No Customer ID';
                      
                      return Column(
                        children: [
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'my_qr_code'.tr,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.customerId.value.isNotEmpty 
                                ? 'Customer ID: ${controller.customerId.value}'
                                : userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: ThemeService.purpleGradient,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.info_outline, color: Colors.white),
                     SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Show this QR code to Employees to earn points',
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

