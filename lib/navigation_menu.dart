// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/features/views/calendar/calendar_view.dart';
import 'package:daily_mate/features/views/home/home_view.dart';
import 'package:daily_mate/features/views/quick_tools/quick_tools_view.dart';
// import 'package:daily_mate/features/views/quick_tools/quick_tools_view.dart';
import 'package:daily_mate/features/views/quotes/quotes_view.dart';
import 'package:daily_mate/features/views/settings_/setting_view.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DashboardView extends StatelessWidget {

  DashboardView({super.key});

  final DasboardController navController = Get.put(DasboardController(),permanent: true);
  

  final List<Widget> pages = [
    HomeView(),
    CalendarView(),
    QuickToolsView(),
    QuotesView(),
    SettingView()
  ];

  @override
 Widget build(BuildContext context) {
    final darkmode = THelperFunctions.isDarkMode(context);

    return Obx(
      () => Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            return await navController.onWillPop(context);
          },
          child: pages[navController.currentIndex.value],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: darkmode ? TColors.dark : TColors.light,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navController.tabs.length, (index) {
              final isSelected = navController.currentIndex.value == index;
              final tab = navController.tabs[index];

              return InkWell(
                onTap: () => navController.changeTab(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutBack,
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? TColors.primary
                            : Colors.transparent,
                      ),
                      child: Icon(
                        tab['icon'],
                        color: isSelected
                            ? Colors.white
                            : TColors.darkGrey,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: isSelected
                            ? (darkmode
                                ? TColors.textWhite
                                : TColors.textPrimary)
                            : TColors.darkGrey,
                        fontSize: 12,
                      ),
                      child: Text(tab['label']),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}


class DasboardController extends GetxController {
  var currentIndex = 0.obs;

   // Convert to a getter that evaluates translations dynamically
  List<Map<String, dynamic>> get tabs => [
    {'icon': Iconsax.home_15, 'label': TTexts.home.tr},
    {'icon': Iconsax.calendar5, 'label': TTexts.calendar.tr},
    {'icon': Iconsax.category5, 'label': TTexts.quickTools.tr},
    {'icon': Iconsax.message5, 'label': TTexts.quotes.tr},
    {'icon': Icons.settings, 'label': TTexts.settings.tr},
  ];
  /// --------------- Twice Back Press With App Exit Dialog --------------------///
  DateTime? currentBackPressTime;
  Future<bool> onWillPop(BuildContext context) async {
    DateTime now = DateTime.now();

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      return false; // Don't exit yet
    } else {
      exitAppDialog(context); // Show dialog on second press
      return false; // Prevent immediate exit
    }
  }

    void changeTab(int index) {
    currentIndex.value = index;
  }


  void exitAppDialog(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final darkmode = THelperFunctions.isDarkMode(context);

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Exit App",
            style: textStyle.headlineMedium?.copyWith(
              color: TColors.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: TSizes.spaceBtwItems / 2.5),
          Text(
            "Are you sure you want to close the application?",
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
              Expanded(
                child: TAppOutlinedButton(
                  onPressed: () => Get.back(),
                  text: TTexts.no.tr,
                  height: 36,
                  borderColor: TColors.accent,
                  textColor: TColors.accent,
                ),
              ),
              SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: TAppButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  text: TTexts.yes.tr,
                  height: 36,
                  color: TColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
