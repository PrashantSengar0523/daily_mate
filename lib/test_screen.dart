// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/settings_controller/water_reminder_controller.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TestScreen extends StatelessWidget {
  TestScreen({super.key});

  final WaterReminderController controller = Get.put(
    WaterReminderController(),
    tag: "WaterReminderController",
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Text(
          "Water Reminder",
          style: textStyle.titleSmall?.copyWith(color: TColors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: TSizes.md / 1.5),
        child: Column(
          children: [
            SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showShadow: !isDark ,
              backgroundColor: Colors.deepOrange.withOpacity(0.1),
              showBorder: isDark,
              borderColor: Colors.deepOrangeAccent.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepOrange.withOpacity(0.2),
                        child: const Icon(
                          Iconsax.glass5,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Expanded(
                        child: Text(
                          "How much water do you want to drink in a day?",
                          style: textStyle.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems / 2),
                  Obx(
                    () => Slider(
                      value: controller.targetMl.value.toDouble(),
                      min: 1000,
                      max: 5000,
                      divisions: 8,
                      activeColor: Colors.deepOrange,
                      label: "${controller.targetMl.value} ml",
                      onChanged:
                          (val) => controller.targetMl.value = val.round(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(
                      () => Text(
                        "Goal: ${controller.targetMl.value} ml",
                        style: textStyle.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              backgroundColor: Colors.amberAccent.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              showBorder: isDark,
              showShadow: !isDark ,
              borderColor: Colors.deepOrangeAccent.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: TColors.secondary.withOpacity(0.2),
                        child: const Icon(
                          Icons.local_cafe,
                          color: TColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "What’s your usual cup size?",
                          style: textStyle.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark?TColors.textWhite:TColors.textPrimary
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cup size options
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final size in [200, 250, 300, 350])
                          GestureDetector(
                            onTap: () => controller.cupSize.value = size,
                            child: TRoundedContainer(
                              showShadow: false,
                              backgroundColor:
                                  controller.cupSize.value == size
                                      ? TColors.secondary
                                      : (Colors.transparent),
                              showBorder: controller.cupSize.value != size,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              radius: 12,
                              child: Text(
                                "$size ml",
                                style: textStyle.bodyMedium?.copyWith(
                                  color:
                                      controller.cupSize.value == size
                                          ? TColors.white
                                          : (isDark
                                              ? TColors.textWhite
                                              : TColors.textSecondary),
                                ),
                              ),
                            ),
                          ),

                        // Custom option
                        GestureDetector(
                          onTap: () async {
                            final customController = TextEditingController();
                            final customSize = await TDialogs.defaultDialog(
                              context: context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Enter Cup size",
                                    style: textStyle.headlineSmall,
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),

                                  /// Input field
                                  TTextField(
                                    controller: customController,
                                    hintText: "Eg. 220 ml",
                                    textInputType: TextInputType.number,
                                  ),

                                  const SizedBox(height: TSizes.defaultSpace),

                                  /// Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TAppOutlinedButton(
                                          text: "Cancel",
                                          height: 40,
                                          onPressed:
                                              () => Navigator.pop(
                                                context,
                                              ), // just close
                                        ),
                                      ),
                                      const SizedBox(
                                        width: TSizes.spaceBtwItems,
                                      ),
                                      Expanded(
                                        child: TAppButton(
                                          text: "Save",
                                          height: 40,
                                          onPressed: () {
                                            final size = int.tryParse(
                                              customController.text.trim(),
                                            );
                                            Navigator.pop(
                                              context,
                                              size,
                                            ); // ✅ return size
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );

                            if (customSize != null && customSize > 0) {
                              controller.cupSize.value = customSize;
                            }
                          },
                          child: TRoundedContainer(
                            backgroundColor:
                                ![
                                      200,
                                      250,
                                      300,
                                      350,
                                    ].contains(controller.cupSize.value)
                                    ? TColors.secondary
                                    : Colors.transparent,
                            showBorder: true,
                            showShadow: false,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            radius: 12,
                            child: Text(
                              "Custom",
                              style: textStyle.bodyMedium?.copyWith(
                                color:
                                    ![
                                          200,
                                          250,
                                          300,
                                          350,
                                        ].contains(controller.cupSize.value)
                                        ? TColors.white
                                        : (isDark
                                            ? TColors.textWhite
                                            : TColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              backgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
              padding: const EdgeInsets.all(14),
              showBorder: isDark,
              showShadow: !isDark ,
              borderColor: Colors.deepPurpleAccent.withOpacity(0.2),
              radius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⏰ Daily Routine",
                    style: textStyle.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark?TColors.textWhite:TColors.textPrimary
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Wakeup & Sleep in same row
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime:
                                    controller.startTime.value ??
                                    const TimeOfDay(hour: 7, minute: 0),
                              );
                              if (picked != null)controller.startTime.value = picked;
                            },
                            child: TRoundedContainer(
                              backgroundColor: Colors.deepPurpleAccent,
                              showShadow: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              radius: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.sunny,
                                    color: TColors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    controller.startTime.value != null
                                        ? controller.startTime.value!.format(
                                          context,
                                        )
                                        : "Wake",
                                    style: textStyle.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: TColors.textWhite
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime:
                                    controller.endTime.value ??
                                    const TimeOfDay(hour: 22, minute: 0),
                              );
                              if (picked != null)controller.endTime.value = picked;
                            },
                            child: TRoundedContainer(
                              backgroundColor: Colors.deepPurpleAccent,
                              showShadow: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              radius: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.nightlight_round,
                                    color: TColors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    controller.endTime.value != null
                                        ? controller.endTime.value!.format(
                                          context,
                                        )
                                        : "Sleep",
                                    style: textStyle.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: TColors.textWhite
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems,),
              Obx(() {
                    if (controller.startTime.value == null ||
                        controller.endTime.value == null ||
                        controller.targetMl.value == 0 ||
                        controller.cupSize.value == 0) {
                      return const SizedBox.shrink();
                    }

                    // Calculate interval
                    final start = controller.startTime.value!;
                    final end = controller.endTime.value!;
                    final totalMinutes =
                        (end.hour * 60 + end.minute) -
                        (start.hour * 60 + start.minute);
                    final totalHours = (totalMinutes / 60).floor();
                    final totalCups =
                        (controller.targetMl.value /
                                (controller.cupSize.value ?? 1))
                            .ceil();

                    final interval =
                        totalHours > 0
                            ? (totalHours ~/ totalCups)
                            : 0; // hours between reminders

                    return TRoundedContainer(
                      backgroundColor: Colors.tealAccent.withOpacity(0.1),
                      showShadow: !isDark,
                      showBorder: isDark,
                      borderColor: Colors.tealAccent.withOpacity(0.2),
                      padding: const EdgeInsets.all(16),
                      radius: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "📋 Summary",
                            style: textStyle.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "You'll get $totalCups reminders between "
                            "${start.format(Get.context!)} and ${end.format(Get.context!)}.",
                            style: textStyle.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TAppButton(
          height: 48,
          textsize: TSizes.fontSizeMd,
          text: "Save",
          onPressed: () {
            controller.saveWaterReminder();
          },
        ),
      ),
    );
  }
}
