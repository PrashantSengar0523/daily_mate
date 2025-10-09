import 'package:daily_mate/navigation_menu.dart';
import 'package:get/get.dart';

import '../features/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController(), fenix: true);
  }
}

class DashbardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DasboardController(), fenix: true);
  }
}


