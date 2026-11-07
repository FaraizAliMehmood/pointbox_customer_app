import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pointbox_mobile/app/modules/profile/controllers/profile_controller.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/bottom_nav_bar.dart';
import 'package:pointbox_mobile/app/widgets/gradient_app_bar.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Scaffold(
        appBar: GradientAppBar(
          title: 'profile'.tr,
          showBackButton: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: ThemeService.purpleGradient,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        controller.userName.value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.userEmail.value,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Obx(
                                  () => Text(
                                    '${controller.totalPoints.value}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                                Text(
                                  'total_points'.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey[300],
                            ),
                            Column(
                              children: [
                                Obx(
                                  () => Text(
                                    '${controller.linkedBrands.length}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                                Text(
                                  'linked_accounts'.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('linked_accounts'.tr),
                    const SizedBox(height: 12),
                    Obx(
                      () => controller.linkedBrands.isEmpty
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'no_brands'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.linkedBrands.length,
                              itemBuilder: (context, index) {
                                final brand = controller.linkedBrands[index];

                                // Backend sends companyName/companyLogo as flat fields on the
                                // linked-company entry (company is just the company's id, not
                                // a nested object).
                                final brandName = brand['companyName'] ?? "";
                                final brandPoints = brand['points'] ?? 0;

                                final tierPoints = brand['tier_points'];

                                final logoUrl = (brand['companyLogo'] ?? '').toString();
                                final hasLogo = logoUrl.isNotEmpty;

                                // Tier data returned by the API for this linked company.
                                // Only real tiers the company has configured are shown —
                                // no client-side Silver/Gold/Platinum estimate.
                                final tierInfo = brand['tier'] is Map<String, dynamic>
                                    ? brand['tier'] as Map<String, dynamic>
                                    : null;
                                final tierName = tierInfo?['name']?.toString();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Colors.purple[100],
                                              radius: 24,
                                              child: hasLogo
                                                  ? ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: logoUrl,
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => const Center(
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => const Icon(
                                                          Icons.store,
                                                          color: Colors.purple,
                                                        ),
                                                      ),
                                                    )
                                                  : const Icon(Icons.store, color: Colors.purple),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    brandName.toString(),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text('${'Redeem Points:'.tr} $brandPoints'),
                                                ],
                                              ),
                                            ),
                                            if (tierName != null) _buildTierBadge(tierName),
                                          ],
                                        ),
                                        if (tierInfo != null) ...[
                                          const Divider(height: 20),
                                          _buildTierProgressBar(
                                            tierInfo,
                                            (tierPoints as num?) ?? 0,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${'Expires'.tr}: ${_formatExpiry(tierInfo['expiryDate'])}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('qr_code'.tr),
                    const SizedBox(height: 12),
                    Card(
                      child: InkWell(
                        onTap: controller.showQRCode,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Colors.purple,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'my_qr_code'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'scan_qr'.tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('personal_info'.tr),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.cake_outlined, color: Colors.purple),
                        title: Text('date_of_birth'.tr),
                        subtitle: Obx(
                          () => Text(
                            controller.dateOfBirth.value.isEmpty ? '-' : controller.dateOfBirth.value,
                          ),
                        ),
                        trailing: Obx(
                          () => controller.isUpdatingDateOfBirth.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.edit, color: Colors.purple, size: 20),
                        ),
                        onTap: () => controller.pickAndUpdateDateOfBirth(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('settings'.tr),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.language, color: Colors.purple),
                            title: Text('change_language'.tr),
                            subtitle: Text(Get.locale?.languageCode == 'ar' ? 'arabic'.tr : 'english'.tr),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: controller.changeLanguage,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: Text('logout'.tr),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: controller.logout,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            title: Text('delete_account'.tr),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: controller.deleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Build tier badge widget
  Widget _buildTierBadge(String tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF9333EA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF9333EA), width: 1.5),
      ),
      child: Text(
        tier,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Gradient progress bar showing how far the customer is through the
  /// current tier's point range, filled with the app's own purple gradient.
  Widget _buildTierProgressBar(Map<String, dynamic> tierInfo, num tierPoints) {
    final minPoints = (tierInfo['minPoints'] as num?) ?? 0;
    final maxPoints = tierInfo['maxPoints'] as num?;

    const gradient = ThemeService.purpleLinearGradient;

    double progress;
    if (maxPoints == null) {
      progress = 1.0;
    } else {
      final range = maxPoints - minPoints;
      progress = range <= 0 ? 1.0 : ((tierPoints - minPoints) / range).clamp(0.0, 1.0).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 10, color: Colors.grey[200]),
              LayoutBuilder(
                builder: (context, constraints) => Container(
                  height: 10,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${minPoints.toInt()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              maxPoints != null ? '${maxPoints.toInt()}' : 'No limit'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  /// Format the tier's expiry date, or show "No expiry" when the tier never expires
  String _formatExpiry(dynamic expiryDate) {
    if (expiryDate == null) return 'No expiry'.tr;
    final parsed = DateTime.tryParse(expiryDate.toString());
    if (parsed == null) return 'No expiry'.tr;
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}

