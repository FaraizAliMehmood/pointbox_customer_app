import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Use put instead of lazyPut to keep controller persistent across auth screens
    // This prevents TextEditingController disposal issues
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: false);
    }
  }
}

