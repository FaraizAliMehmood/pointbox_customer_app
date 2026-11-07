import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/support/controllers/support_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}

