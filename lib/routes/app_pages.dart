

import 'package:daily_mate/navigation_menu.dart';
import 'package:get/get.dart';
import '../features/views/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static String initialRoute = AppRoutes.splashView;

  static final List<GetPage> pages = [
  /// ------------- Auth Pages ------------------ ///  
    GetPage(
        name: AppRoutes.splashView,
        page: () => SplashView(),),
   
  
  /// ------------- App Pages ------------------ ///
   GetPage(
        name: AppRoutes.dashboardView,
        page: () => DashboardView(),),

  ];
}
