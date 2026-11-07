import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';
import 'package:pointbox_mobile/app/modules/profile/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    // Use put instead of lazyPut to ensure controller is initialized immediately
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }
}

