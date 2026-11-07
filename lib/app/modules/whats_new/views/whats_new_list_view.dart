import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';
import 'package:pointbox_mobile/app/widgets/whats_new_card.dart';

class WhatsNewListView extends GetView<HomeController> {
  const WhatsNewListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        body: Container(
          decoration: ThemeService.purpleGradient,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Text(
                          'whats_new'.tr,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Obx(() {
                      if (controller.isLoadingWhatsNew.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.whatsNewItems.isEmpty) {
                        return Center(
                          child: Text(
                            'no_whats_new'.tr,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => Get.find<HomeController>().refreshHome(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: controller.whatsNewItems.length,
                          itemBuilder: (context, index) {
                            final item = controller.whatsNewItems[index];
                            return WhatsNewCard(
                              item: item,
                              fullWidth: true,
                              onTap: () => Get.toNamed(
                                AppRoutes.WHATS_NEW_DETAIL,
                                arguments: item,
                              ),
                            );
                          },
                        ),
                      );
                    }),
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
