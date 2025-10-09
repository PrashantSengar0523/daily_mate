// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/settings_controller/water_reminder_controller.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class WaterReminderView extends StatelessWidget {
  WaterReminderView({super.key});

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
          TTexts.waterReminder.tr,
          style: textStyle.titleSmall?.copyWith(color: TColors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: TSizes.md / 1.5),
        child: Column(
          children: [
            SizedBox(height: TSizes.spaceBtwItems),
            Obx(() {
              if (controller.activeReminder.value == -1) {
                return Container();
              }

              return TRoundedContainer(
                backgroundColor: TColors.error.withOpacity(0.08),
                padding: const EdgeInsets.all(16),
                radius: 16,
                showBorder: isDark,
                showShadow: false,
                borderColor: TColors.error.withOpacity(0.3),
                child: Row(
                  children: [
                    // Icon
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: TColors.error.withOpacity(0.2),
                      child: const Icon(
                        Icons.alarm_on_rounded,
                        color: TColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TTexts.activeReminder.tr,
                            style: textStyle.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TColors.error,
                            ),
                          ),
                          // const SizedBox(height: 4),
                          // Text(
                          //   "${controller.startTime.value?.format(Get.context!) ?? "--"} "
                          //   "to ${controller.endTime.value?.format(Get.context!) ?? "--"}",
                          //   style: textStyle.bodyMedium?.copyWith(
                          //     color: TColors.textSecondary,
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Actions: Edit + Delete
                    Row(
                      children: [
                        // IconButton(
                        //   onPressed: () {
                        //     // open edit flow (reselect times, target, cupsize)
                        //     controller.resetFields();
                        //   },
                        //   icon: const Icon(
                        //     Icons.mode_edit_outline,
                        //     color: TColors.primary,
                        //   ),
                        //   tooltip: "Edit Reminder",
                        // ),
                        IconButton(
                          onPressed: () {
                            controller.deleteReminder();
                            controller.activeReminder.value=-1;
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: TColors.error,
                          ),
                          tooltip: "Delete Reminder",
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: TSizes.spaceBtwItems),
            TRoundedContainer(
              showShadow: !isDark,
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
                          TTexts.waterDrinkInADay.tr,
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
                        "${TTexts.goal.tr}: ${controller.targetMl.value} ml",
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
              showShadow: !isDark,
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
                          TTexts.waterSetReminder.tr,
                          style: textStyle.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? TColors.textWhite
                                    : TColors.textPrimary,
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
                        for (final size in controller.cupSizes)
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
                                    TTexts.enterValue.tr,
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
                                          text: TTexts.cancel.tr  ,
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
                                          text: TTexts.save.tr ,
                                          height: 40,
                                          onPressed: () {
                                            final size = int.tryParse(
                                              customController.text.trim(),
                                            );
                                            controller.addCustomCupSize(size??200);
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
                              TTexts.custom.tr,
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
              showShadow: !isDark,
              borderColor: Colors.deepPurpleAccent.withOpacity(0.2),
              radius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TTexts.dailyRoutine.tr,
                    style: textStyle.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TColors.textWhite : TColors.textPrimary,
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
                              if (picked != null)
                                controller.startTime.value = picked;
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
                                        : TTexts.wakeUp.tr,
                                    style: textStyle.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: TColors.textWhite,
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
                                        : TTexts.sleepTab.tr,
                                    style: textStyle.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: TColors.textWhite,
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
            SizedBox(height: TSizes.spaceBtwItems),
            Obx(() {
              if (controller.startTime.value == null ||
                  controller.endTime.value == null ||
                  controller.targetMl.value == 0 ||
                  controller.cupSize.value == 0) {
                return const SizedBox.shrink();
              }

              final start = controller.startTime.value!;
              final end = controller.endTime.value!;
              final startTotal = start.hour * 60 + start.minute;
              final endTotal = end.hour * 60 + end.minute;

              // total cups/reminders
              final totalCups =
                  (controller.targetMl.value / (controller.cupSize.value ?? 1))
                      .ceil();

              final totalMinutes = endTotal - startTotal;
              if (totalMinutes <= 0) return const SizedBox.shrink();

              final intervalMinutes = (totalMinutes / totalCups).floor();

              // 🔹 Generate reminder times
              final times = <String>[];
              for (int i = 0; i < totalCups; i++) {
                final minutes = startTotal + (i * intervalMinutes);
                final hour = minutes ~/ 60;
                final minute = minutes % 60;

                final time = TimeOfDay(hour: hour, minute: minute);
                times.add(time.format(Get.context!));
              }

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
                      "📋 ${TTexts.summary.tr}",
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          times
                              .map(
                                (t) => Chip(
                                  label: Text(t),
                                  backgroundColor: Colors.teal.withOpacity(0.2),
                                ),
                              )
                              .toList(),
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
          text: TTexts.save.tr,
          onPressed: () {
            // controller.testReminder();
            controller.saveWaterReminder();
          },
        ),
      ),
    );
  }
}
