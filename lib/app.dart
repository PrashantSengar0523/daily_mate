import 'package:daily_mate/localization/text_localization.dart';
import 'package:daily_mate/routes/app_pages.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'utils/constants/colors.dart';
import 'features/views/splash/splash_view.dart';
import 'utils/constants/text_strings.dart';
import 'utils/theme/theme.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    themeController.updateStatusBar(context);
    return Obx(
      () => GetMaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        translations: TTextLocalization(),
        fallbackLocale: Locale('en', 'US'),
        locale: storageService.getSavedLocale(),
        title: TTexts.appName,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        themeMode: themeController.themeMode,
        debugShowCheckedModeBanner: false,
        getPages: AppPages.pages,
        home: SplashView(),
      ),
    );
  }
}
