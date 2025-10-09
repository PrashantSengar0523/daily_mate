import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../common/widgets/app_button/t_app_button.dart';
import '../constants/sizes.dart';
import '../helpers/helper_functions.dart';
import '../theme/theme_controller.dart';


class TDialogs {
  

  static defaultDialog({
    required BuildContext context,
    Function()? onCancel,
    Function()? onConfirm,
    Widget? child,
  }) {

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dialog",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 800),
      transitionBuilder: (context, animation, secondaryAnimation, childWidget) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // smooth spring-like curve
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: childWidget,
          ),
        );
      },
      pageBuilder: (context, animation1, animation2) {
        return WillPopScope(
          onWillPop: () async => true,
          child: AlertDialog(
            
            // backgroundColor: TColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(TSizes.md),
            content: child ?? const SizedBox(),
          ),
        );
      },
    );
  }

  

   /// Show Simple Toast
static void customToast({
  required String message,
  Color? color,
  Color? textColor,
  bool? isSucces,
  bool? showAtTop, // Add this parameter
}) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      padding: EdgeInsets.all(TSizes.sm),
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      margin: showAtTop == true 
          ? EdgeInsets.only(top: 50, left: 20, right: 20) 
          : null,
      duration: const Duration(seconds: 5),
      backgroundColor: color ?? (isSucces ?? false ? TColors.success : TColors.error),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
           color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        )
      ),
    ),
  );
}

  /// Show Success Toast
  static showSuccessToast({required String? message}) {
    if (message == null) {
      return;
    }
    Get.closeAllSnackbars();
    Get.snackbar(
      "SUCCESS",
      message,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      backgroundColor: Colors.green,
      borderRadius: 12,
      snackPosition: SnackPosition.TOP,
      colorText: Colors.black,
      titleText: Text(
        "SUCCESS",
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
        ),
      ),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 600),
      messageText: Text(
        message,
        textAlign: TextAlign.start,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Show Error Toast
  static showErrorToast({required String? message}) {
    if (message == null) {
      return;
    }
    Get.closeAllSnackbars();
    Get.snackbar(
      "ERROR",
      message,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      backgroundColor: Colors.red,
      borderRadius: 12,
      snackPosition: SnackPosition.TOP,
      colorText: Colors.black,
      titleText: Text(
        "ERROR",
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
        ),
      ),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 600),
      messageText: Text(
        message,
        textAlign: TextAlign.start,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Theme Change dialog
  static showChangeThemeDialog(BuildContext context) {
    final ThemeController themeController = Get.find();

    AppThemeMode selectedTheme = themeController.currentTheme.value;

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Switch Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              activeColor: TColors.primary,
              value: mode,
              groupValue: selectedTheme,
              title: Text(mode.name.capitalizeFirst ?? mode.name),
              onChanged: (AppThemeMode? newMode) {
                if (newMode != null) {
                  themeController.setTheme(context, newMode);
                  Get.back(); // Closes the dialog
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Delete Account dialog
    static deleteAccountDialog(BuildContext context, {required VoidCallback onPressed, bool? isLoading}) {
    final textStyle = Theme.of(context).textTheme;
    final darkmode = THelperFunctions.isDarkMode(context);

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Account Delete",
            style: textStyle.headlineMedium?.copyWith(
              color: TColors.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: TSizes.spaceBtwItems / 2.5),
          Text(
            "Are you sure you want to permanently delete your account?",
            textAlign: TextAlign.center,
            style: textStyle.headlineMedium?.copyWith(
              color: darkmode ? TColors.grey : TColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: TSizes.md / 1.15,
            ),
          ),
          SizedBox(height: TSizes.spaceBtwItems),

          Row(
            children: [
              Expanded(child: TAppOutlinedButton(text: "No", height: 36,onPressed: (){Get.back();},)),
              SizedBox(width: TSizes.spaceBtwItems),
              Expanded(child: TAppButton(text: "Yes", height: 36,
              onPressed: onPressed)),
            ],
          ),
        ],
      ),
    );
  }


}
