// ignore_for_file: deprecated_member_use, avoid_print

import 'package:daily_mate/features/controllers/settings_controller/exercise_reminder_controller.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/utils/constants/sizes.dart';

class ExerciseReminderView extends StatelessWidget {
  ExerciseReminderView({super.key});

  final ExerciseReminderController controller = Get.put(ExerciseReminderController());

  final List<TimeOfDay> quickTimes = [
    const TimeOfDay(hour: 6, minute: 0),
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
  ];

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Text(
          TTexts.exerciseReminder.tr,
          style: textStyle.titleSmall?.copyWith(color: TColors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (controller.activeExerciseReminder.isEmpty) {
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
                          const SizedBox(height: 4),
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

            // 1️⃣ Intro Card
            TRoundedContainer(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              showShadow: true,
              radius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🏃 ${TTexts.exerciseReminderTitle.tr}",
                    style: textStyle.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TTexts.exerciseReminderSubTitle.tr  ,
                    style: textStyle.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2️⃣ Selected Reminder Card
            Obx(() => TRoundedContainer(
                  padding: const EdgeInsets.all(16),
                  showShadow: true,
                  showBorder: isDark,
                  borderColor: Colors.lightBlueAccent.withOpacity(0.2),
                  backgroundColor: Colors.lightBlueAccent.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          controller.reminderTime.value != null
                              ? "${TTexts.exerciseTime.tr}: ${controller.reminderTime.value!.format(context)}"
                              : TTexts.exerciseTime.tr,
                          style: textStyle.bodyMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime:
                                controller.reminderTime.value ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            controller.reminderTime.value = picked;
                          }
                        },
                        icon: const Icon(Icons.access_time),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),

            // 3️⃣ Quick Pick Buttons
            Text(
              TTexts.quickSelectTime.tr,
              style: textStyle.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: quickTimes
                  .map((t) => GestureDetector(
                        onTap: () => controller.reminderTime.value = t,
                        child: TRoundedContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          radius: 12,
                          showShadow: false,
                          showBorder: controller.reminderTime.value == t,
                          backgroundColor: controller.reminderTime.value == t
                              ? Colors.blueAccent
                              : Colors.transparent,
                          child: Text(
                            t.format(context),
                            style: textStyle.bodyMedium?.copyWith(
                              color: controller.reminderTime.value == t
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 30),

           
          ],
        ),
      ),
       bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: TAppButton(
          height: 48,
          textsize: TSizes.fontSizeMd,
          text: TTexts.save.tr,
          onPressed: () async{
            // controller.debugTimeZone();
            print("Exercis Time :${controller.reminderTime.value}");
            controller.saveReminder();
            // controller.verifyDailyRepeat();
          },
        ),
      ),
    );
  }
}
