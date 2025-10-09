// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../controllers/quick_tool_controller/health_controller.dart';

final controller = Get.put(HealthController());

class SleepSummaryCard extends StatelessWidget {
  const SleepSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Helper function to get dynamic sleep quality text
    String getSleepQuality(double percent) {
      if (percent >= 0.9)return "${TTexts.excellent.tr} ${TTexts.sleepTab.tr}!";
      if (percent >= 0.7) return "${TTexts.good.tr} ${TTexts.sleepTab.tr}!";
      if (percent >= 0.5) return "${TTexts.fair.tr} ${TTexts.sleepTab.tr}!";
      return "${TTexts.poor.tr} ${TTexts.sleepTab.tr}!";
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title
          Text(
            "${TTexts.lastNight.tr} ${TTexts.sleepTab.tr}",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),

          Obx(() {
            // Clamp todaySleep to prevent over-display
            final todaySleep = controller.todaySleep.value.clamp(
              0.0,
              controller.sleepGoal.value,
            );
            final percent = (todaySleep / controller.sleepGoal.value).clamp(
              0.0,
              1.0,
            );
            return Row(
              children: [
                // Circular Progress Ring
                CircularPercentIndicator(
                  radius: 72,
                  lineWidth: 12,
                  percent: percent,
                  progressColor: Colors.orangeAccent,
                  backgroundColor: Colors.white24,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${todaySleep.toStringAsFixed(1)} ${TTexts.hrs.tr}",
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${TTexts.of.tr} ${controller.sleepGoal.value.toStringAsFixed(1)} ${TTexts.hrs.tr}",
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                // Sleep Info: Bedtime & Wakeup
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoTile(
                        "Bedtime",
                        controller.bedtime.value != null
                            ? controller.bedtime.value!.format(context)
                            : "10:30 PM",
                        Icons.bedtime,
                        textTheme,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoTile(
                        "Wake Up",
                        controller.wakeupTime.value != null
                            ? controller.wakeupTime.value!.format(context)
                            : "6:30 AM",
                        Icons.wb_sunny,
                        textTheme,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          // Dynamic Sleep Quality Indicator
          Obx(() {
            final todaySleep = controller.todaySleep.value.clamp(
              0.0,
              controller.sleepGoal.value,
            );
            final percent = (todaySleep / controller.sleepGoal.value).clamp(
              0.0,
              1.0,
            );
            final sleepQuality = getSleepQuality(percent);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sentiment_satisfied, color: Colors.yellowAccent),
                  const SizedBox(width: 6),
                  Text(
                    sleepQuality,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Reusable Info Tile for Bedtime/Wakeup
  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    TextTheme textTheme,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: TSizes.iconMd),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SleepAddAndGoal extends StatelessWidget {
  const SleepAddAndGoal({
    super.key,
    required this.isDark,
    required this.title,
    required this.value,
    required this.darkModeColor,
    required this.lightModeColor,
  });
  final String title;
  final String value;
  final Color darkModeColor;
  final Color lightModeColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? darkModeColor : lightModeColor,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Value
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: TColors.lightGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklySleepChart extends StatelessWidget {
  const WeeklySleepChart({super.key});

  /// Prepare weekly data (Mon → Sun)
  List<Map<String, dynamic>> getWeeklySleepData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(date);
      final dayName = DateFormat('EEE').format(date); // Mon, Tue...
      final hasData = controller.dailySleep.containsKey(key);
      final hours =
          hasData
              ? controller.dailySleep[key]!.clamp(
                0.0,
                controller.sleepGoal.value,
              )
              : 0.0;
      return {"day": dayName, "hours": hours, "hasData": hasData};
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final sleepData = getWeeklySleepData();


    return TRoundedContainer(
      padding: EdgeInsets.all(TSizes.sm),
      backgroundColor: isDark ? TColors.dark : TColors.light,
      height: 240,
      child: SfCartesianChart(
        title: ChartTitle(
          alignment: ChartAlignment.near,
          text: "Weekly Overview",
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TColors.textWhite : TColors.textPrimary,
          ),
        ),
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        primaryYAxis: NumericAxis(),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          borderColor: Colors.blueAccent,
          borderWidth: 1,
          color: Colors.white,
          textStyle: const TextStyle(color: Colors.black),
        ),
        series: <CartesianSeries>[
          ColumnSeries<Map<String, dynamic>, String>(
            dataSource: sleepData,
            xValueMapper: (data, _) => data["day"],
            yValueMapper: (data, _) => data["hours"],
            borderRadius: BorderRadius.circular(10),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }

}

class SleepBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> sleepData;
  final double maxYAxis;

  const SleepBarChart({
    super.key,
    required this.sleepData,
    required this.maxYAxis,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: maxYAxis,
        interval: 2,
        labelFormat: '{value}h',
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: sleepData,
          xValueMapper: (data, _) => data["day"],
          yValueMapper: (data, _) => data["hours"],
          pointColorMapper:
              (data, _) =>
                  data["hasData"] ? const Color(0xFF4facfe) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          width: 0.3,
          spacing: 0.25,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
