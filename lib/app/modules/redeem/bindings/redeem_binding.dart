import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/redeem/controllers/redeem_controller.dart';

class RedeemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedeemController>(() => RedeemController());
  }
}

