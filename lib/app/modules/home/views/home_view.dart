import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';
import 'package:pointbox_mobile/app/services/storage_service.dart';
import 'package:pointbox_mobile/app/services/theme_service.dart';
import 'package:pointbox_mobile/app/widgets/bottom_nav_bar.dart';
import 'package:pointbox_mobile/app/widgets/responsive_layout.dart';
import 'package:pointbox_mobile/app/widgets/special_event_banner.dart';
import 'package:pointbox_mobile/app/widgets/regular_banner.dart';
import 'package:pointbox_mobile/app/widgets/whats_new_card.dart';
import 'package:pointbox_mobile/app/widgets/recent_company_card.dart';
import 'package:pointbox_mobile/app/widgets/top_claim_product_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _hasFetchedProfile = false;
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    // Fetch profile when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasFetchedProfile) {
        controller.fetchProfile();
        _hasFetchedProfile = true;
      }
    });
  }

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'home'.tr,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Obx(
                            () => Text(
                              'Hello, ${controller.userName.value}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _NotificationIconWithBadge(),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: controller.refreshHome,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            // Regular Banners with auto-animation
                            Obx(
                              () {
                                if (controller.isLoadingBanners.value) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (controller.regularBanners.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return SizedBox(
                                  height: 220,
                                  child: PageView.builder(
                                    controller:
                                        controller.regularBannerPageController,
                                    onPageChanged:
                                        controller.onRegularBannerPageChanged,
                                    itemCount: controller.regularBanners.length,
                                    itemBuilder: (context, index) {
                                      return RegularBanner(
                                        banner:
                                            controller.regularBanners[index],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient:
                                        ThemeService.purpleGradient.gradient,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'total_points'.tr,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.18),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '${controller.totalPoints.value}',
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Obx(
                              () {
                                if (controller.isLoadingWhatsNew.value) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'whats_new'.tr,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Get.toNamed(AppRoutes.WHATS_NEW),
                                          child: Text(
                                            'see_all'.tr,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    controller.whatsNewItems.isEmpty
                                        ? SizedBox(
                                            height: 175,
                                            child: Center(
                                              child: Text(
                                                'no_whats_new'.tr,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 175,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller
                                                  .whatsNewItems.length,
                                              itemBuilder: (context, index) {
                                                return WhatsNewCard(
                                                  item: controller
                                                      .whatsNewItems[index],
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Obx(
                              () {
                                if (controller.isLoadingRecentCompanies.value) {
                                  return const SizedBox.shrink();
                                }

                                if (controller.recentCompanies.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'new_brands'.tr,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              Get.toNamed(AppRoutes.BRANDS),
                                          child: Text(
                                            'see_all'.tr,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 175,
                                      child: ListView.builder(
                                        controller: controller
                                            .recentCompaniesScrollController,
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            controller.recentCompanies.length,
                                        itemBuilder: (context, index) {
                                          return RecentCompanyCard(
                                            company: controller
                                                .recentCompanies[index],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Obx(
                              () {
                                if (controller.isLoadingTopClaimProducts.value) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'top_claim_offers'.tr,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Get.toNamed(
                                              AppRoutes.REDEEM_POINTS),
                                          child: Text(
                                            'see_all'.tr,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    controller.topClaimProducts.isEmpty
                                        ? SizedBox(
                                            height: 175,
                                            child: Center(
                                              child: Text(
                                                'no_top_claim_offers'.tr,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 175,
                                            child: ListView.builder(
                                              controller: controller
                                                  .topClaimProductsScrollController,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: controller
                                                  .topClaimProducts.length,
                                              itemBuilder: (context, index) {
                                                return TopClaimProductCard(
                                                  product: controller
                                                      .topClaimProducts[index],
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildMenuGrid(context),
                            const SizedBox(height: 24),
                            Text(
                              'promotional_banners'.tr,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Obx(
                              () {
                                if (controller.isLoadingBanners.value) {
                                  return const SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (controller.specialEventBanners.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return SizedBox(
                                  height: 240,
                                  child: PageView.builder(
                                    controller: controller
                                        .specialEventBannerPageController,
                                    onPageChanged: controller
                                        .onSpecialEventBannerPageChanged,
                                    itemCount:
                                        controller.specialEventBanners.length,
                                    itemBuilder: (context, index) {
                                      return SpecialEventBanner(
                                        banner: controller
                                            .specialEventBanners[index],
                                      );
                                    },
                                  ),
                                );
                              },
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
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menuItems = [
      {
        'title': 'Available Offers'.tr,
        'icon': Icons.redeem,
        'route': AppRoutes.REDEEM_POINTS,
        'color': Colors.orange,
      },
      {
        'title': 'contact_support'.tr,
        'icon': Icons.support_agent,
        'route': AppRoutes.CONTACT_SUPPORT,
        'color': Colors.blue,
      },
      {
        'title': 'reviews'.tr,
        'icon': Icons.stars_sharp,
        'route': AppRoutes.REVIEWS,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => Get.toNamed(item['route'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 24,
                    color: item['color'] as Color,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationIconWithBadge extends StatefulWidget {
  @override
  _NotificationIconWithBadgeState createState() =>
      _NotificationIconWithBadgeState();
}

class _NotificationIconWithBadgeState
    extends State<_NotificationIconWithBadge> {
  int _unreadCount = 0;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    // Backend has no live-update channel for this count, so poll
    // periodically while the home screen is open.
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final storage = Get.find<StorageService>();
      final token = storage.getString('auth_token');
      if (token == null || token.isEmpty) return;

      final response = await ApiService.getUnreadNotificationCount();
      if (mounted && response['success'] == true && response['data'] != null) {
        setState(() {
          _unreadCount = (response['data']['unreadCount'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      // Leave the badge as-is on failure (e.g. not logged in yet, offline).
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () async {
            await Get.toNamed(AppRoutes.NOTIFICATIONS);
            _loadUnreadCount();
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _unreadCount > 9 ? 5 : 4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                shape:
                    _unreadCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    _unreadCount > 9 ? BorderRadius.circular(10) : null,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
