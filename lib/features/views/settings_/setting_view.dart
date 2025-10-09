// ignore_for_file: deprecated_member_use, unused_import

import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/features/views/settings_/subscreens/admin_view.dart';
import 'package:daily_mate/features/views/settings_/subscreens/excercise_reminder_view.dart';
import 'package:daily_mate/features/views/settings_/subscreens/medicine_reminder_view.dart';
import 'package:daily_mate/features/views/settings_/subscreens/water_reminder_view.dart';
import 'package:daily_mate/localization/language_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// import '../../../utils/helpers/helper_functions.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    // final isDark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TCommonAppBar(
        appBarWidget: Row(
          children: [
            Text(
              TTexts.settings.tr,
              style: textStyle.titleMedium?.copyWith(
                color: TColors.textWhite,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: TSizes.md),
        child: Column(
          children: [
            SizedBox(height: TSizes.spaceBtwItems),
            AccountWidget(
              onTap: () {
                Get.to(() => WaterReminderView());
              },
              textStyle: textStyle,
              widgetName: TTexts.waterReminder.tr,
              widgetIcon: Iconsax.drop3,
            ),
            AccountWidget(
              onTap: () {
                Get.to(() => ExerciseReminderView());
              },
              textStyle: textStyle,
              widgetName: TTexts.exerciseReminder.tr,
              widgetIcon: Icons.sports_gymnastics_rounded,
            ),
            AccountWidget(
              onTap: () {
                Get.to(() => MedicineReminderView());
              },
              textStyle: textStyle,
              widgetName:  TTexts.medicineReminder.tr,
              widgetIcon: Icons.medical_information_rounded,
            ),
            // AccountWidget(
            //   onTap: () {

            //   },
            //   textStyle: textStyle,
            //   widgetName: "Notification",
            //   widgetIcon: Iconsax.notification5,
            // ),

            // AccountWidget(
            //   onTap: () {

            //   },
            //   textStyle: textStyle,
            //   widgetName: "Subscription",
            //   widgetIcon: Icons.subscriptions_rounded,
            // ),
            AccountWidget(
              onTap: () {
                TDialogs.showChangeThemeDialog(context);
              },
              textStyle: textStyle,
              widgetName: TTexts.themeMode.tr,
              widgetIcon: Icons.dark_mode_rounded,
            ),

            AccountWidget(
              onTap: () {
                showChangeLanguageDialog(context);
              },
              textStyle: textStyle,
              widgetName: TTexts.language.tr,
              widgetIcon: Icons.language_rounded,
            ),
            // AccountWidget(
            //   onTap: () {
            //    Get.to(()=>AdminView());
            //   },
            //   textStyle: textStyle,
            //   widgetName: "Admin",
            //   widgetIcon: Icons.admin_panel_settings_rounded,
            // ),
          ],
        ),
      ),
    );
  }

  void showChangeLanguageDialog(BuildContext context) {
    final LanguageController controller = Get.put(
      LanguageController(),
      tag: "LanguageController",
    );
    TDialogs.defaultDialog(
      context: context,
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              activeColor: TColors.primary,
              title: Text("English"),
              value: 'en',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.updateLanguage(value); // Update language and save
                }
              },
            ),
            RadioListTile<String>(
              activeColor: TColors.primary,
              title: Text("हिंदी"),
              value: 'hi',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.updateLanguage(value); // Update language and save
                }
              },
            ),
            SizedBox(height: TSizes.spaceBtwItems),

            /// **Update Button**
            TAppButton(
              text: TTexts.tUpdate.tr,
              color: TColors.secondary,
              textColor: TColors.textWhite,
              onPressed: () {
                Get.back(); // Close bottom sheet after language change
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AccountWidget extends StatelessWidget {
  const AccountWidget({
    super.key,
    required this.textStyle,
    required this.widgetName,
    required this.widgetIcon,
    this.onTap,
  });

  final TextTheme textStyle;
  final String widgetName;
  final IconData widgetIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
      onTap: onTap,
      showShadow: false,
      margin: EdgeInsets.only(bottom: TSizes.md),
      backgroundColor: TColors.secondary.withOpacity(0.15),
      child: Row(
        children: [
          Icon(widgetIcon, color: TColors.secondary),
          SizedBox(width: TSizes.spaceBtwItems),
          Text(widgetName, style: textStyle.titleLarge),
          Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: TColors.secondary,
            size: TSizes.iconMd / 1.2,
          ),
        ],
      ),
    );
  }
}
