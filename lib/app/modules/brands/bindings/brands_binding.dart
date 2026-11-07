import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/brands/controllers/brands_controller.dart';
import 'package:pointbox_mobile/app/modules/home/controllers/home_controller.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    Get.lazyPut<BrandsController>(() => BrandsController());
  }
}

