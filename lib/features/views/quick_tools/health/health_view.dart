import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/health_controller.dart';
import 'package:daily_mate/features/views/quick_tools/health/sleep_tab_widgets.dart';
import 'package:daily_mate/features/views/quick_tools/health/steps_tab_widgets.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthView extends StatelessWidget {
  HealthView({super.key});

  final controller = Get.put(HealthController());

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TCommonAppBar(
          showBackArrow: true,
          appBarWidget: Row(
            children: [
              Text(
                TTexts.health.tr,
                style: textTheme.titleMedium?.copyWith(
                  color: TColors.textWhite,
                ),
              ),
            ],
          ),
          actions: [IconButton(
        icon: Icon(Icons.picture_as_pdf, color: TColors.textWhite),
        onPressed: () => controller.generateWeeklyReport(),
        tooltip: 'Generate Weekly Report',
      ),],
        ),
        body: Column(
          children: [
            /// 🔹 Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Material(
                color: isDark ? TColors.black : TColors.light,
                child: TabBar(
                  dividerColor: Colors.transparent,
                  isScrollable: false, // equal width
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white70 : Colors.black87,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: TColors.primary,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: TColors.primary,
                          ), // unselected border
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(TTexts.steps.tr ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: TColors.primary,
                          ), // unselected border
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(TTexts.sleepTab.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔹 Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildStepsTab(context, textTheme),
                  _buildSleepTab(context, textTheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsTab(BuildContext context, TextTheme textTheme) {
    return Obx(
      () => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 🔹 Set Daily Goal
            TRoundedContainer(
              onTap: () => _showGoalDialog(context, controller),
              radius: 12,
              backgroundColor: TColors.secondary,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${TTexts.dailyGoal.tr}: ${controller.dailyGoal.value} ${TTexts.steps.tr}",
                      style: textTheme.titleMedium?.copyWith(
                        color: TColors.textWhite,
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: TColors.white,
                    child: Icon(Icons.add, color: TColors.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Steps Progress Card
            StepsProgressCard(
              currentSteps: controller.steps.value,
              goalSteps: controller.dailyGoal.value,
            ),
            const SizedBox(height: 16),

            StepsStatusCard(),
            const SizedBox(height: 24),

            /// Stats Row
            Row(
              children: [
                Expanded(
                  child: StepsStatCard(
                    title: TTexts.calories.tr,
                    value:
                        "${(controller.steps.value * 0.04).toStringAsFixed(1)} Kcal",
                    icon: Icons.local_fire_department,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StepsStatCard(
                    title: TTexts.distance.tr,
                    value:
                        "${(controller.steps.value * 0.0008).toStringAsFixed(2)} km",
                    icon: Icons.map,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StepsStatCard(
                    title: TTexts.time.tr,
                    value: "${(controller.steps.value ~/ 100)} min",
                    icon: Icons.timer,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: TSizes.spaceBtwItems,),
            StepsWeeklyChart(controller: controller, context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTab(BuildContext context, TextTheme textTheme) {
    final isDark = THelperFunctions.isDarkMode(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              /// Sleep Goal Card
              Expanded(
                child: Obx(() {
                  return InkWell(
                    onTap: () {
                      showAddSleepGoalDialog(context);
                    },
                    child: SleepAddAndGoal(
                      isDark: isDark,
                      title: TTexts.sleepGoal.tr,
                      value:
                          '${controller.sleepGoal.value.toStringAsFixed(1)} hrs',
                      darkModeColor: const Color(0xFF264653),
                      lightModeColor: const Color(0xFF2A9D8F),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),

              /// Add Today’s Sleep Button
              Expanded(
                child: Obx(() {
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      showAddSleepDialog(context);
                    },
                    child: SleepAddAndGoal(
                      isDark: isDark,
                      title: "+ ${TTexts.todaySleep.tr}",
                      value:
                          '${controller.todaySleep.value.toStringAsFixed(1)} ${TTexts.hrs.tr}',
                      darkModeColor: const Color(0xFFE76F51),
                      lightModeColor: const Color(0xFFF4A261),
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// Last Night’s Sleep Summary
          SleepSummaryCard(),
          const SizedBox(height: 24),

          /// Weekly Chart
          WeeklySleepChart(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Goal setting dialog
  void _showGoalDialog(BuildContext context, HealthController controller) {
  final textController = TextEditingController(
    text: controller.dailyGoal.value.toString(),
  );

  TDialogs.defaultDialog(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// Title
        Text(
          TTexts.setYourGoal.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        /// Input
        TTextField(
          controller: textController,
          textInputType: TextInputType.number,
            hintText: TTexts.enterValue.tr,
       

        ),
        const SizedBox(height: 20),

        /// Buttons
        Row(
          children: [
            Expanded(
              child: TAppOutlinedButton(
                text: TTexts.cancel.tr ,
                height: 40,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TAppButton(
                text: TTexts.save.tr ,
                height: 40,
                onPressed: () {
                  final goal = int.tryParse(textController.text) ?? 1000;
                  controller.setGoal(goal);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  void showAddSleepDialog(BuildContext context) {
    TimeOfDay? selectedBedtime = controller.bedtime.value;
    TimeOfDay? selectedWakeup = controller.wakeupTime.value;

    // Persistent controllers
    final bedtimeController = TextEditingController(
      text: selectedBedtime != null ? selectedBedtime.format(context) : "",
    );
    final wakeupController = TextEditingController(
      text: selectedWakeup != null ? selectedWakeup.format(context) : "",
    );

    // Check if user has already logged sleep today
    final isSleepLogged = controller.isSleepLoggedToday();

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TTexts.logSleep.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TSizes.defaultSpace),

          /// Bedtime
          TTextField(
            readOnly: true,
            controller: bedtimeController,
            hintText: TTexts.bedtime.tr,
            suffixIcon: InkWell(
              onTap:
                  isSleepLogged
                      ? null
                      : () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime:
                              selectedBedtime ?? TimeOfDay(hour: 22, minute: 0),
                        );
                        if (time != null) {
                          selectedBedtime = time;
                          bedtimeController.text = time.format(context);
                        }
                      },
              child: const Icon(Icons.bedtime),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Wake-up Time
          TTextField(
            readOnly: true,
            controller: wakeupController,
            hintText: TTexts.wakeUp.tr,
            suffixIcon: InkWell(
              onTap:
                  isSleepLogged
                      ? null
                      : () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime:
                              selectedWakeup ?? TimeOfDay(hour: 6, minute: 30),
                        );
                        if (time != null) {
                          selectedWakeup = time;
                          wakeupController.text = time.format(context);
                        }
                      },
              child: const Icon(Icons.wb_sunny),
            ),
          ),
          const SizedBox(height: TSizes.defaultSpace),

          /// Save Button
          TAppButton(
            text: isSleepLogged ? TTexts.sleepAlreadyLogged.tr : TTexts.save.tr,
            onPressed:
                isSleepLogged
                    ? null
                    : () {
                      if (selectedBedtime != null)
                        controller.bedtime.value = selectedBedtime;
                      if (selectedWakeup != null)
                        controller.wakeupTime.value = selectedWakeup;

                      final sleepDuration =
                          selectedWakeup != null && selectedBedtime != null
                              ? ((selectedWakeup!.hour +
                                          selectedWakeup!.minute / 60) -
                                      (selectedBedtime!.hour +
                                          selectedBedtime!.minute / 60))
                                  .abs()
                              : 0.0;

                      controller.logTodaySleep(sleepDuration);

                      Navigator.pop(context);
                    },
          ),
        ],
      ),
    );
  }

  void showAddSleepGoalDialog(BuildContext context) {
    double sleepGoal = controller.sleepGoal.value;

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TTexts.sleepGoal.tr,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TSizes.defaultSpace),

          /// Sleep Goal Input (Hours)
          TTextField(
            textInputType: TextInputType.number,
            hintText: TTexts.enterValue.tr,
            controller: TextEditingController(
              text: sleepGoal.toStringAsFixed(1),
            ),
            onChanged: (value) {
              sleepGoal = double.tryParse(value) ?? sleepGoal;
            },
          ),
          const SizedBox(height: TSizes.defaultSpace),

          /// Save Button
          TAppButton(
            text: TTexts.save.tr,
            onPressed: () {
              controller.setSleepGoal(sleepGoal);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }


}

