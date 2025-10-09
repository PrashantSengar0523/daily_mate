import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/features/models/hoilday_model.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


class THolidayCard extends StatelessWidget {
  const THolidayCard({
    super.key,
    required this.isToday,
    required this.isDark,
    required this.holiday,
    required this.textStyle,
  });

  final bool isToday;
  final bool isDark;
  final HolidayModel holiday;
  final TextTheme textStyle;

  @override
  Widget build(BuildContext context) {
    return TRoundedContainer(
                          width: double.infinity,
                          backgroundColor: isToday 
      ? TColors.secondary.withOpacity(0.1)
      : (isDark ? TColors.darkerGrey : TColors.lightGrey),
                          radius: 16,
                          padding: const EdgeInsets.symmetric(
      horizontal: TSizes.md, vertical: TSizes.sm),
                          margin: const EdgeInsets.only(
      bottom: TSizes.sm, right: TSizes.md, left: TSizes.md),
                          child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isToday 
              ? TColors.secondary
              : Colors.deepOrange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isToday ? Iconsax.calendar_tick : Iconsax.calendar5,
          color: Colors.white,
          size: 20,
        ),
      ),
      SizedBox(width: TSizes.spaceBtwItems),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    holiday.name,
                    style: textStyle.titleSmall?.copyWith(
                      color: isDark
                          ? TColors.textWhite
                          : TColors.textPrimary,
                      fontWeight: isToday 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: TColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Today",
                      style: textStyle.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 4),
            Text(
              THelperFunctions.getFormattedDate(
                holiday.date,
                format: "EEEE, d MMMM yyyy",
              ),
              style: textStyle.labelMedium?.copyWith(
                color: isToday 
                    ? TColors.secondary
                    :isDark? TColors.grey:TColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
                          ),
                        );
  }
}
