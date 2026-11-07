import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Obx(
      () => Container(
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'home'.tr,
                index: 0,
                isSelected: controller.currentIndex.value == 0,
                onTap: () => controller.changePage(0),
              ),
              _buildNavItem(
                icon: Icons.card_giftcard_outlined,
                selectedIcon: Icons.card_giftcard,
                label: 'brands'.tr,
                index: 1,
                isSelected: controller.currentIndex.value == 1,
                onTap: () => controller.changePage(1),
              ),
              _buildQRCenterButton(
                onTap: () => Get.toNamed(AppRoutes.QR_CODE),
              ),
              _buildNavItem(
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                label: 'transaction_history'.tr,
                index: 3,
                isSelected: controller.currentIndex.value == 3,
                onTap: () => controller.changePage(3),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'profile'.tr,
                index: 4,
                isSelected: controller.currentIndex.value == 4,
                onTap: () => controller.changePage(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFF9333EA) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF9333EA) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCenterButton({required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF9333EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'QR Code'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9333EA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

