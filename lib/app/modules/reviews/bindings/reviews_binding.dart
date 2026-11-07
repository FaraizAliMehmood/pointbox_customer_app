import 'package:get/get.dart';
import 'package:pointbox_mobile/app/modules/reviews/controllers/reviews_controller.dart';

class ReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewsController>(() => ReviewsController());
  }
}
