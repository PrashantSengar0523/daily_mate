// ignore_for_file: deprecated_member_use, avoid_print


import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/settings_controller/medicine_reminder_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MedicineReminderView extends StatelessWidget {
  MedicineReminderView({super.key});

  final MedicineReminderController controller = Get.put(
    MedicineReminderController(),
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Text(
          TTexts.medicineReminder.tr,
          style: textStyle.titleSmall?.copyWith(color: TColors.white),
        ),
        actions: [
          InkWell(
            onTap: () {
              _showActiveRemindersSheet(context);
            },
            child: Icon(Icons.list_alt_rounded, color: TColors.white),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: TSizes.md / 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: TSizes.spaceBtwItems),
            
            /// Active reminders summary
            Obx(() {
              if (controller.activeMedicineReminders.isEmpty) {
                return Container();
              }

              return TRoundedContainer(
                backgroundColor: TColors.success.withOpacity(0.08),
                padding: const EdgeInsets.all(16),
                radius: 16,
                showBorder: isDark,
                showShadow: false,
                borderColor: TColors.success.withOpacity(0.3),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: TColors.success.withOpacity(0.2),
                      child: Text(
                        "${controller.activeMedicineReminders.length}",
                        style: textStyle.titleMedium?.copyWith(
                          color: TColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${controller.activeMedicineReminders.length} ${TTexts.activeReminder.tr}",
                            style: textStyle.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: TColors.success,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap to view all reminders",
                            style: textStyle.bodySmall?.copyWith(
                              color: TColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showActiveRemindersSheet(context);
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: TColors.success,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: TSizes.spaceBtwItems),

            /// Medicine name input
            TRoundedContainer(
              backgroundColor: Colors.tealAccent.withOpacity(0.1),
              showShadow: isDark,
              borderColor: Colors.tealAccent.withOpacity(0.2),
              padding: const EdgeInsets.all(16),
              radius: 16,
              showBorder: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💊 ${TTexts.medicineName.tr}",
                    style: textStyle.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TColors.textWhite : TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TTextField(
                    controller: controller.medicineName,
                    hintText: TTexts.enterValue.tr,
                  ),
                ],
              ),
            ),

            SizedBox(height: TSizes.spaceBtwItems),

            /// Reminder time
            TRoundedContainer(
              backgroundColor: Colors.deepPurple.withOpacity(0.08),
              showShadow: isDark,
              borderColor: Colors.deepPurpleAccent.withOpacity(0.2),
              padding: const EdgeInsets.all(16),
              radius: 16,
              showBorder: isDark,
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "⏰ ${TTexts.reminderTime.tr}",
                      style: textStyle.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TColors.textWhite : TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: controller.reminderTime.value ??
                              const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (picked != null) controller.reminderTime.value = picked;
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
                            const Icon(Iconsax.clock, color: TColors.white),
                            const SizedBox(width: 6),
                            Text(
                              controller.reminderTime.value != null
                                  ? controller.reminderTime.value!.format(context)
                                  : TTexts.selectTime.tr,
                              style: textStyle.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: TColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            SizedBox(height: TSizes.spaceBtwItems),

            /// Duration
            TRoundedContainer(
              width: double.infinity,
              backgroundColor: Colors.greenAccent.withOpacity(0.08),
              showShadow: isDark,
              borderColor: Colors.greenAccent.withOpacity(0.2),
              padding: const EdgeInsets.all(16),
              radius: 16,
              showBorder: isDark,
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📅 ${TTexts.duration.tr}",
                      style: textStyle.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TColors.textWhite : TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _durationChip(TTexts.onlyToday.tr, 1),
                        _durationChip("7 Days", 7),
                        _durationChip("15 Days", 15),
                        GestureDetector(
                          onTap: () async {
                            final customController = TextEditingController();

                            final result = await TDialogs.defaultDialog(
                              context: context,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    TTexts.duration.tr,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  TTextField(
                                    controller: customController,
                                    textInputType: TextInputType.number,
                                    hintText: TTexts.enterValue.tr,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TAppOutlinedButton(
                                          onPressed: () => Navigator.pop(context),
                                          text: TTexts.cancel.tr,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TAppButton(
                                          onPressed: () {
                                            final val = int.tryParse(
                                              customController.text.trim(),
                                            );
                                            Navigator.pop(context, val);
                                          },
                                          text: TTexts.save.tr,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );

                            if (result != null && result > 0) {
                              controller.selectedDuration.value = result;
                              controller.customDays.value = result;
                            }
                          },
                          child: TRoundedContainer(
                            showShadow: false,
                            backgroundColor: controller.customDays.value != null
                                ? TColors.secondary
                                : Colors.transparent,
                            showBorder: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            radius: 12,
                            child: Text(
                              controller.customDays.value != null
                                  ? "${controller.customDays.value} Days"
                                  : TTexts.custom.tr,
                              style: textStyle.bodyMedium?.copyWith(
                                color: controller.customDays.value != null
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
                  ],
                );
              }),
            ),
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
            controller.saveReminder();
          },
        ),
      ),
    );
  }

  Widget _durationChip(String label, int days) {
    return Obx(() {
      final isSelected = controller.selectedDuration.value == days;
      return GestureDetector(
        onTap: () {
          controller.selectedDuration.value = days;
          controller.customDays.value = null;
        },
        child: TRoundedContainer(
          showShadow: false,
          backgroundColor: isSelected ? TColors.secondary : Colors.transparent,
          showBorder: !isSelected,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          radius: 12,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? TColors.white : TColors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  /// Show bottom sheet with all active reminders
  void _showActiveRemindersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Active Reminders",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (controller.activeMedicineReminders.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteAllReminders();
                        },
                        child: Text("Clear All"),
                      ),
                  ],
                ),
              ),
              Divider(),
              // List of reminders
              Expanded(
                child: Obx(() {
                  if (controller.activeMedicineReminders.isEmpty) {
                    return Center(
                      child: Text("No active reminders"),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: controller.activeMedicineReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = controller.activeMedicineReminders[index];
                      return _buildReminderCard(context, reminder);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, Map<String, dynamic> reminder) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: TRoundedContainer(
        backgroundColor: TColors.primary.withOpacity(0.08),
        padding: const EdgeInsets.all(16),
        radius: 16,
        showBorder: isDark,
        borderColor: TColors.primary.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication_rounded, color: TColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reminder["medicineName"],
                    style: textStyle.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.deleteReminder(reminder["id"]);
                  },
                  icon: Icon(Icons.delete_outline, color: TColors.error),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: TColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  controller.getFormattedTime(reminder),
                  style: textStyle.bodyMedium,
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${controller.getRemainingDays(reminder)} days left",
                    style: textStyle.bodySmall?.copyWith(
                      color: TColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
// import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
// import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
// import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
// import 'package:daily_mate/features/controllers/settings_controller/medicine_reminder_controller.dart';
// import 'package:daily_mate/utils/constants/colors.dart';
// import 'package:daily_mate/utils/constants/sizes.dart';
// import 'package:daily_mate/utils/constants/text_strings.dart';
// import 'package:daily_mate/utils/helpers/helper_functions.dart';
// import 'package:daily_mate/utils/popups/dialogs.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';

// class MedicineReminderView extends StatelessWidget {
//   MedicineReminderView({super.key});

//   final MedicineReminderController controller = Get.put(
//     MedicineReminderController(),
//   );

//   @override
//   Widget build(BuildContext context) {
//     final textStyle = Theme.of(context).textTheme;
//     final isDark = THelperFunctions.isDarkMode(context);

//     return Scaffold(
//       appBar: TCommonAppBar(
//         showBackArrow: true,
//         appBarWidget: Text(
//           TTexts.medicineReminder.tr,
//           style: textStyle.titleSmall?.copyWith(color: TColors.white),
//         ),
//         actions: [
//           InkWell(
//             onTap: (){

//             },
//             child: Icon(Icons.list_alt_rounded,color: TColors.white,))
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: TSizes.md / 1.5),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: TSizes.spaceBtwItems),
//             Obx(() {
//               if (controller.activeMedicineReminder.isEmpty) {
//                 return Container();
//               }

//               return TRoundedContainer(
//                 backgroundColor: TColors.error.withOpacity(0.08),
//                 padding: const EdgeInsets.all(16),
//                 radius: 16,
//                 showBorder: isDark,
//                 showShadow: false,
//                 borderColor: TColors.error.withOpacity(0.3),
//                 child: Row(
//                   children: [
//                     // Icon
//                     CircleAvatar(
//                       radius: 22,
//                       backgroundColor: TColors.error.withOpacity(0.2),
//                       child: const Icon(
//                         Icons.alarm_on_rounded,
//                         color: TColors.error,
//                       ),
//                     ),
//                     const SizedBox(width: 12),

//                     // Text
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             TTexts.activeReminder.tr,
//                             style: textStyle.bodyLarge?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: TColors.error,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           // Text(
//                           //   "${controller.startTime.value?.format(Get.context!) ?? "--"} "
//                           //   "to ${controller.endTime.value?.format(Get.context!) ?? "--"}",
//                           //   style: textStyle.bodyMedium?.copyWith(
//                           //     color: TColors.textSecondary,
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                     ),

//                     // Actions: Edit + Delete
//                     Row(
//                       children: [
//                         // IconButton(
//                         //   onPressed: () {},
//                         //   icon: const Icon(
//                         //     Icons.mode_edit_outline,
//                         //     color: TColors.primary,
//                         //   ),
//                         //   tooltip: "Edit Reminder",
//                         // ),
//                         IconButton(
//                           onPressed: () {
//                             controller.deleteReminder();
//                           },
//                           icon: const Icon(
//                             Icons.delete_forever_rounded,
//                             color: TColors.error,
//                           ),
//                           tooltip: "Delete Reminder",
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }),

//             /// Medicine name input
//             TRoundedContainer(
//               backgroundColor: Colors.tealAccent.withOpacity(0.1),
//               showShadow: isDark,
//               borderColor: Colors.tealAccent.withOpacity(0.2),
//               padding: const EdgeInsets.all(16),
//               radius: 16,
//               showBorder: isDark,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "💊 ${TTexts.medicineName.tr}",
//                     style: textStyle.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? TColors.textWhite : TColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TTextField(
//                     controller: controller.medicineName,
//                     hintText: TTexts.enterValue.tr,
//                     // onChanged: (val) => controller.medicineName.text = val,
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: TSizes.spaceBtwItems),

//             /// Reminder time
//             TRoundedContainer(
//               backgroundColor: Colors.deepPurple.withOpacity(0.08),
//               showShadow: isDark,
//               borderColor: Colors.deepPurpleAccent.withOpacity(0.2),
//               padding: const EdgeInsets.all(16),
//               radius: 16,
//               showBorder: isDark,
//               child: Obx(() {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "⏰ ${TTexts.reminderTime.tr}",
//                       style: textStyle.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: isDark ? TColors.textWhite : TColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     GestureDetector(
//                       onTap: () async {
//                         final picked = await showTimePicker(
//                           context: context,
//                           initialTime:
//                               controller.reminderTime.value ??
//                               const TimeOfDay(hour: 8, minute: 0),
//                         );
//                         if (picked != null)controller.reminderTime.value = picked;
//                       },
//                       child: TRoundedContainer(
//                         backgroundColor: Colors.deepPurpleAccent,
//                         showShadow: true,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                         radius: 12,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Iconsax.clock, color: TColors.white),
//                             const SizedBox(width: 6),
//                             Text(
//                               controller.reminderTime.value != null
//                                   ? controller.reminderTime.value!.format(
//                                     context,
//                                   )
//                                   : TTexts.selectTime.tr,
//                               style: textStyle.bodyMedium?.copyWith(
//                                 fontWeight: FontWeight.w500,
//                                 color: TColors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),

//             SizedBox(height: TSizes.spaceBtwItems),

//             /// Duration
//             TRoundedContainer(
//               width: double.infinity,
//               backgroundColor: Colors.greenAccent.withOpacity(0.08),
//               showShadow: isDark,
//               borderColor: Colors.greenAccent.withOpacity(0.2),
//               padding: const EdgeInsets.all(16),
//               radius: 16,
//               showBorder: isDark,
//               child: Obx(() {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "📅 ${TTexts.duration.tr}",
//                       style: textStyle.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: isDark ? TColors.textWhite : TColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _durationChip(TTexts.onlyToday.tr, 1),
//                         _durationChip("7 Days", 7),
//                         _durationChip("15 Days", 15),
//                         GestureDetector(
//                           onTap: () async {
//                             final customController = TextEditingController();

//                             final result = TDialogs.defaultDialog(
//                               context: context,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     TTexts.duration.tr,
//                                     style:
//                                         Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   const SizedBox(height: 16),
//                                   TTextField(
//                                     controller: customController,
//                                     textInputType: TextInputType.number,
//                                     hintText: TTexts.enterValue.tr,
//                                   ),
//                                   const SizedBox(height: 20),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: TAppOutlinedButton(
//                                           onPressed:
//                                               () => Navigator.pop(context),
//                                           text: TTexts.cancel.tr,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: TAppButton(
//                                           onPressed: () {
//                                             final val = int.tryParse(
//                                               customController.text.trim(),
//                                             );
//                                             Navigator.pop(context, val);
//                                           },
//                                           text: TTexts.save.tr,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             );

//                             if (result != null && result > 0) {
//                               controller.selectedDuration.value = result;
//                               controller.customDays.value = result;
//                             }
//                           },

//                           child: TRoundedContainer(
//                             showShadow: false,
//                             backgroundColor:
//                                 controller.customDays.value != null
//                                     ? TColors.secondary
//                                     : Colors.transparent,
//                             showBorder: true,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                             radius: 12,
//                             child: Text(
//                               controller.customDays.value != null
//                                   ? "${controller.customDays.value} Days"
//                                   : TTexts.custom.tr,
//                               style: textStyle.bodyMedium?.copyWith(
//                                 color:
//                                     controller.customDays.value != null
//                                         ? TColors.white
//                                         : (isDark
//                                             ? TColors.textWhite
//                                             : TColors.textSecondary),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: TAppButton(
//           height: 48,
//           textsize: TSizes.fontSizeMd,
//           text: TTexts.save.tr,
//           onPressed: () {
//             print("Medicine Name :${controller.medicineName}");
//             print("Time :${controller.reminderTime.value}");
//             print("Days :${controller.selectedDuration.value}");
//             controller.saveReminder();
//           },
//         ),
//       ),
//     );
//   }

//   Widget _durationChip(String label, int days) {
//     return Obx(() {
//       final isSelected = controller.selectedDuration.value == days;
//       return GestureDetector(
//         onTap: () {
//           controller.selectedDuration.value = days;
//           controller.customDays.value = null; // reset custom
//         },
//         child: TRoundedContainer(
//           showShadow: false,
//           backgroundColor: isSelected ? TColors.secondary : Colors.transparent,
//           showBorder: !isSelected,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           radius: 12,
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? TColors.white : TColors.textSecondary,
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
