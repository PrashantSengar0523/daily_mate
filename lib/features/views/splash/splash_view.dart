import 'package:daily_mate/features/controllers/splash_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/system_overlay/t_system_overlay_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final SplashController controller = Get.put(
    SplashController(),
    tag: "SplashController",
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    TSystemOverlayUi.setStatusBarTheme(Brightness.light);

    return Scaffold(
      backgroundColor: TColors.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// App Title / Logo
          Text(
            TTexts.appName.tr,
            style: textStyle.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: TColors.textWhite,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Subtitle
          Text(
            "Your Daily Productivity Partner",
            style: textStyle.titleSmall?.copyWith(color: TColors.light),
          ),

          const SizedBox(height: TSizes.spaceBtwSections),

          /// Animated Loader
          const SpinKitThreeBounce(color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
