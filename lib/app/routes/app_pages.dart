import 'package:get/get.dart';
import 'package:pointbox_mobile/app/routes/app_routes.dart';
import 'package:pointbox_mobile/app/modules/auth/bindings/auth_binding.dart';
import 'package:pointbox_mobile/app/modules/auth/views/login_view.dart';
import 'package:pointbox_mobile/app/modules/auth/views/signup_view.dart';
import 'package:pointbox_mobile/app/modules/auth/views/otp_view.dart';
import 'package:pointbox_mobile/app/modules/auth/views/check_email.dart';
import 'package:pointbox_mobile/app/modules/auth/views/reset_password.dart';
import 'package:pointbox_mobile/app/modules/splash/views/splash_view.dart';
import 'package:pointbox_mobile/app/modules/home/bindings/home_binding.dart';
import 'package:pointbox_mobile/app/modules/home/views/home_view.dart';
import 'package:pointbox_mobile/app/modules/profile/bindings/profile_binding.dart';
import 'package:pointbox_mobile/app/modules/profile/views/profile_view.dart';
import 'package:pointbox_mobile/app/modules/redeem/bindings/redeem_binding.dart';
import 'package:pointbox_mobile/app/modules/redeem/views/redeem_view.dart';
import 'package:pointbox_mobile/app/modules/conversion/bindings/conversion_binding.dart';
import 'package:pointbox_mobile/app/modules/conversion/views/conversion_view.dart';
import 'package:pointbox_mobile/app/modules/transactions/bindings/transactions_binding.dart';
import 'package:pointbox_mobile/app/modules/transactions/views/transactions_view.dart';
import 'package:pointbox_mobile/app/modules/support/bindings/support_binding.dart';
import 'package:pointbox_mobile/app/modules/support/views/support_view.dart';
import 'package:pointbox_mobile/app/modules/brands/bindings/brands_binding.dart';
import 'package:pointbox_mobile/app/modules/brands/views/brands_view.dart';
import 'package:pointbox_mobile/app/modules/profile/views/qr_code_view.dart';
import 'package:pointbox_mobile/app/modules/reviews/bindings/reviews_binding.dart';
import 'package:pointbox_mobile/app/modules/reviews/views/reviews_view.dart';
import 'package:pointbox_mobile/app/modules/notifications/bindings/notifications_binding.dart';
import 'package:pointbox_mobile/app/modules/notifications/views/notifications_view.dart';
import 'package:pointbox_mobile/app/modules/whats_new/views/whats_new_list_view.dart';
import 'package:pointbox_mobile/app/modules/whats_new/views/whats_new_detail_view.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.OTP,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.CHECK_EMAIL,
      page: () => const CheckEmailView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.REDEEM_POINTS,
      page: () => const RedeemView(),
      binding: RedeemBinding(),
    ),
    GetPage(
      name: AppRoutes.CONVERSION_RATE,
      page: () => const ConversionView(),
      binding: ConversionBinding(),
    ),
    GetPage(
      name: AppRoutes.TRANSACTION_HISTORY,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.CONTACT_SUPPORT,
      page: () => const SupportView(),
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.BRANDS,
      page: () => const BrandsView(),
      binding: BrandsBinding(),
    ),
    GetPage(
      name: AppRoutes.QR_CODE,
      page: () => const QRCodeView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.REVIEWS,
      page: () => const ReviewsView(),
      binding: ReviewsBinding(),
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.WHATS_NEW,
      page: () => const WhatsNewListView(),
    ),
    GetPage(
      name: AppRoutes.WHATS_NEW_DETAIL,
      page: () => const WhatsNewDetailView(),
    ),
  ];
}

