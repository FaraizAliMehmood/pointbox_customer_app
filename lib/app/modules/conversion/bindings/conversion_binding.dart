import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/conversion/controllers/conversion_controller.dart';

class ConversionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversionController>(() => ConversionController());
  }
}

