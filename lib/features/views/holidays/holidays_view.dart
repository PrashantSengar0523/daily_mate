// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/cards/holiday_card.dart';
import 'package:daily_mate/common/widgets/loaders/circular_loader.dart';
import 'package:daily_mate/features/controllers/holiday_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HolidaysView extends StatelessWidget {
  HolidaysView({super.key});

  final HolidayController controller = Get.find<HolidayController>();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              TTexts.allHolidays.tr,
              style: textStyle.titleMedium?.copyWith(
                color: TColors.textWhite,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TCircularLoader(),
                SizedBox(height: TSizes.spaceBtwItems),
                Text(TTexts.loading.tr),
              ],
            ),
          );
        }

        final grouped = controller.groupedHolidays;

        // Empty state
        if (grouped.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.calendar,
                  size: 64,
                  color: TColors.grey,
                ),
                SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  "No holidays found 🎉",
                  style: textStyle.titleMedium?.copyWith(
                    color: TColors.grey,
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: () => controller.refreshHolidays(),
                  child: Text("Retry"),
                ),
              ],
            ),
          );
        }

        // Holidays list
        return RefreshIndicator(
          onRefresh: () => controller.refreshHolidays(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: TSizes.defaultSpace),
            children: grouped.entries.map((entry) {
              final month = entry.key;
              final holidays = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month header
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: TSizes.md,
                      vertical: TSizes.sm,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.md,
                      vertical: TSizes.sm,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TColors.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.calendar_1,
                          color: TColors.secondary,
                          size: 20,
                        ),
                        SizedBox(width: TSizes.spaceBtwItems / 2),
                        Text(
                          "$month ${DateTime.now().year}",
                          style: textStyle.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: TColors.secondary,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: TSizes.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${holidays.length}",
                            style: textStyle.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Holiday items
                  ...holidays.map((holiday) {
                    final isToday = controller.todayHoliday.value?.name == holiday.name;
                    
                    return THolidayCard(isToday: isToday, isDark: isDark, holiday: holiday, textStyle: textStyle);
                                      }).toList(),
                ],
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}