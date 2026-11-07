import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';
import 'package:pointbox_mobile/app/models/banner_model.dart';
import 'package:pointbox_mobile/app/models/whats_new_model.dart';
import 'package:pointbox_mobile/app/models/recent_company_model.dart';
import 'package:pointbox_mobile/app/models/top_claim_product_model.dart';
import 'package:pointbox_mobile/app/modules/brands/controllers/brands_controller.dart';
import 'package:pointbox_mobile/app/modules/transactions/controllers/transactions_controller.dart';
import 'package:pointbox_mobile/app/modules/profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final totalPoints = 0.obs;
  final userName = ''.obs;
  final specialEventBanners = <BannerModel>[].obs;
  final regularBanners = <BannerModel>[].obs;
  final isLoadingBanners = false.obs;
  final whatsNewItems = <WhatsNewModel>[].obs;
  final isLoadingWhatsNew = false.obs;
  final recentCompanies = <RecentCompanyModel>[].obs;
  final isLoadingRecentCompanies = false.obs;
  final topClaimProducts = <TopClaimProductModel>[].obs;
  final isLoadingTopClaimProducts = false.obs;
  final currentRegularBannerIndex = 0.obs;
  final currentSpecialEventBannerIndex = 0.obs;
  Timer? _regularBannerTimer;
  Timer? _specialEventBannerTimer;
  Timer? _recentCompaniesTimer;
  Timer? _topClaimProductsTimer;
  final PageController regularBannerPageController = PageController();
  final PageController specialEventBannerPageController = PageController();
  final ScrollController recentCompaniesScrollController = ScrollController();
  final ScrollController topClaimProductsScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    _updateIndexFromRoute();
    _fetchBanners();
    _fetchWhatsNew();
    _fetchRecentCompanies();
    _fetchTopClaimProducts();
  }

  @override
  void onReady() {
    super.onReady();
    _updateIndexFromRoute();
    _startRegularBannerAnimation();
    _startSpecialEventBannerAnimation();
    _startRecentCompaniesAnimation();
    _startTopClaimProductsAnimation();
  }
  
  // Public method to update index from current route
  // Can be called when view becomes visible again
  void updateIndexFromCurrentRoute() {
    _updateIndexFromRoute();
  }

  @override
  void onClose() {
    _regularBannerTimer?.cancel();
    _specialEventBannerTimer?.cancel();
    _recentCompaniesTimer?.cancel();
    _topClaimProductsTimer?.cancel();
    regularBannerPageController.dispose();
    specialEventBannerPageController.dispose();
    recentCompaniesScrollController.dispose();
    topClaimProductsScrollController.dispose();
    super.onClose();
  }



  Future<void> refreshHome() async {
    await Future.wait([
      fetchProfile(),
      _fetchBanners(),
      _fetchWhatsNew(),
      _fetchRecentCompanies(),
      _fetchTopClaimProducts(),
    ]);
  }

  Future<void> fetchProfile() async {
    try {
      final response = await ApiService.getProfile();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        print("Profile response: $data");
        userName.value = data['username'].toString();
        totalPoints.value = data['totalPoints'].toInt();
       
      }
    } catch (e) {
      // Fail silently – keep any current in-memory name/points
      print('Error fetching profile: $e');
    }
  }

  void _updateIndexFromRoute() {
    final currentRoute = Get.currentRoute;
    // Only update index if current route matches one of our bottom nav routes
    // Don't update if on QR_CODE or other modal routes
    if (currentRoute == AppRoutes.HOME) {
      currentIndex.value = 0;
    } else if (currentRoute == AppRoutes.BRANDS) {
      currentIndex.value = 1;
    } else if (currentRoute == AppRoutes.TRANSACTION_HISTORY) {
      currentIndex.value = 3;
    } else if (currentRoute == AppRoutes.PROFILE) {
      currentIndex.value = 4;
    }
    // QR Code (index 2) is a button, not a navigation destination
    // Don't update index for other routes like QR_CODE, REDEEM_POINTS, etc.
  }

  void changePage(int index) {
    if (currentIndex.value == index) return; // Prevent unnecessary navigation
    
    // If we are leaving the Brands tab, clear cached linked brands
    if (currentIndex.value == 1 && index != 1) {
      if (Get.isRegistered<BrandsController>()) {
        Get.find<BrandsController>().clearLinkedBrandsCache();
      }
    }
    
    currentIndex.value = index;
    switch (index) {
      case 0:
        Get.offNamedUntil(AppRoutes.HOME, (route) => route.settings.name == AppRoutes.HOME || route.isFirst);
        // Refresh Home tab data
        fetchProfile();
        _fetchBanners();
        _fetchWhatsNew();
        _fetchRecentCompanies();
        _fetchTopClaimProducts();
        break;
      case 1:
        Get.offNamedUntil(AppRoutes.BRANDS, (route) => route.settings.name == AppRoutes.BRANDS || route.isFirst);
        // Refresh Brands tab data
        if (Get.isRegistered<BrandsController>()) {
          Get.find<BrandsController>().loadBrands();
        }
        break;
      case 3:
        Get.offNamedUntil(AppRoutes.TRANSACTION_HISTORY, (route) => route.settings.name == AppRoutes.TRANSACTION_HISTORY || route.isFirst);
        // Refresh Transactions tab data
        if (Get.isRegistered<TransactionsController>()) {
          Get.find<TransactionsController>().loadTransactions();
        }
        break;
      case 4:
        Get.offNamedUntil(AppRoutes.PROFILE, (route) => route.settings.name == AppRoutes.PROFILE || route.isFirst);
        // Refresh Profile tab data
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadProfile();
        }
        break;
    }
    // Update index after navigation
    _updateIndexFromRoute();
  }

  Future<void> _fetchBanners() async {
    isLoadingBanners.value = true;
    try {
      final response = await ApiService.getBanners();
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> bannersData = response['data'];
        specialEventBanners.value = bannersData
            .where((banner) => banner['type'] == 'special_event' && banner['isActive'] == true)
            .map((banner) => BannerModel.fromJson(banner))
            .toList();
        
        regularBanners.value = bannersData
            .where((banner) => banner['type'] == 'regular' && banner['isActive'] == true)
            .map((banner) => BannerModel.fromJson(banner))
            .toList();
        
        // Restart animations if banners were loaded
        if (regularBanners.isNotEmpty) {
          _startRegularBannerAnimation();
        }
        if (specialEventBanners.isNotEmpty) {
          _startSpecialEventBannerAnimation();
        }
      }
    } catch (e) {
      print('Error fetching banners: $e');
      // Silently fail - don't show error to user for banners
    } finally {
      isLoadingBanners.value = false;
    }
  }

  Future<void> _fetchWhatsNew() async {
    isLoadingWhatsNew.value = true;
    try {
      final response = await ApiService.getWhatsNew();
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        whatsNewItems.value =
            data.map((item) => WhatsNewModel.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching What\'s New items: $e');
      // Silently fail - don't show error to user for this section
    } finally {
      isLoadingWhatsNew.value = false;
    }
  }

  Future<void> _fetchRecentCompanies() async {
    isLoadingRecentCompanies.value = true;
    try {
      final response = await ApiService.getRecentCompanies();
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        recentCompanies.value =
            data.map((item) => RecentCompanyModel.fromJson(item)).toList();

        if (recentCompanies.isNotEmpty) {
          _startRecentCompaniesAnimation();
        }
      }
    } catch (e) {
      print('Error fetching recent companies: $e');
      // Silently fail - don't show error to user for this section
    } finally {
      isLoadingRecentCompanies.value = false;
    }
  }

  void _startRecentCompaniesAnimation() {
    _recentCompaniesTimer?.cancel();

    if (recentCompanies.length < 2) return;

    _recentCompaniesTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!recentCompaniesScrollController.hasClients) return;

      final position = recentCompaniesScrollController.position;
      final cardWidth = Get.width * 0.4 + 12;
      final nextScroll = position.pixels + cardWidth;

      recentCompaniesScrollController.animateTo(
        nextScroll > position.maxScrollExtent ? 0 : nextScroll,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchTopClaimProducts() async {
    isLoadingTopClaimProducts.value = true;
    try {
      final response = await ApiService.getTopClaimProducts();
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        topClaimProducts.value =
            data.map((item) => TopClaimProductModel.fromJson(item)).toList();

        if (topClaimProducts.isNotEmpty) {
          _startTopClaimProductsAnimation();
        }
      }
    } catch (e) {
      print('Error fetching top claim products: $e');
      // Silently fail - don't show error to user for this section
    } finally {
      isLoadingTopClaimProducts.value = false;
    }
  }

  void _startTopClaimProductsAnimation() {
    _topClaimProductsTimer?.cancel();

    if (topClaimProducts.length < 2) return;

    _topClaimProductsTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!topClaimProductsScrollController.hasClients) return;

      final position = topClaimProductsScrollController.position;
      final cardWidth = Get.width * 0.4 + 12;
      final nextScroll = position.pixels + cardWidth;

      topClaimProductsScrollController.animateTo(
        nextScroll > position.maxScrollExtent ? 0 : nextScroll,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startRegularBannerAnimation() {
    _regularBannerTimer?.cancel();
    
    if (regularBanners.isEmpty) return;
    
    _regularBannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (regularBanners.isEmpty) {
        timer.cancel();
        return;
      }
      
      final nextIndex = (currentRegularBannerIndex.value + 1) % regularBanners.length;
      currentRegularBannerIndex.value = nextIndex;
      
      if (regularBannerPageController.hasClients) {
        regularBannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startSpecialEventBannerAnimation() {
    _specialEventBannerTimer?.cancel();
    
    if (specialEventBanners.isEmpty) return;
    
    _specialEventBannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (specialEventBanners.isEmpty) {
        timer.cancel();
        return;
      }
      
      final nextIndex = (currentSpecialEventBannerIndex.value + 1) % specialEventBanners.length;
      currentSpecialEventBannerIndex.value = nextIndex;
      
      if (specialEventBannerPageController.hasClients) {
        specialEventBannerPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onRegularBannerPageChanged(int index) {
    currentRegularBannerIndex.value = index;
    // Reset timer when user manually swipes
    _startRegularBannerAnimation();
  }

  void onSpecialEventBannerPageChanged(int index) {
    currentSpecialEventBannerIndex.value = index;
    // Reset timer when user manually swipes
    _startSpecialEventBannerAnimation();
  }
}

