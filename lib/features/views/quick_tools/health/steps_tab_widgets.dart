import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/health_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StepsStatCard extends StatelessWidget {
  const StepsStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? Colors.blueGrey.shade900 : Colors.white,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with circle background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),

            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepsStatusCard extends StatelessWidget {
  final HealthController controller = Get.put(HealthController());

  StepsStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      color: isDark ? Color(0xFF1E1E2E) : Color(0xFFF0F4FF), // card bg
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          final status = controller.status.value;

          // Status colors
          final statusColor =
              status == "walking"
                  ? (isDark ? Color(0xFF4CD964) : Color(0xFF2E7D32))
                  : (isDark ? Color(0xFFFF6B6B) : Color(0xFFD32F2F));

          final statusIcon =
              status == "walking"
                  ? Icons.directions_walk
                  : Icons.pause_circle_filled;

          return Row(
            children: [
              // Status Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Color(0xFF2C2C3C) : Color(0xFFD9E6FF),
                ),
                child: Icon(statusIcon, size: 36, color: statusColor),
              ),
              const SizedBox(width: 20),

              // Step info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TTexts.steps.tr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${controller.steps.value}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          "${TTexts.status.tr}: $status",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class StepsProgressCard extends StatelessWidget {
  final int currentSteps;
  final int goalSteps;

  const StepsProgressCard({
    super.key,
    required this.currentSteps,
    required this.goalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentSteps / goalSteps).clamp(0, 1);
    final percentage = (progress * 100).toStringAsFixed(0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor =
        progress >= 1
            ? Colors.green
            : progress > 0.7
            ? Colors.orangeAccent
            : Colors.blueAccent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors:
              isDark
                  ? [Colors.blueGrey.shade900, Colors.blueGrey.shade800]
                  : [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left: Big Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              progress >= 1 ? Icons.emoji_events : Icons.directions_walk,
              size: 48,
              color: progressColor,
            ),
          ),
    
          const SizedBox(width: 20),
    
          // Right: Progress Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$currentSteps ${TTexts.of.tr} $goalSteps ${TTexts.steps.tr}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress.toDouble(),
                  color: progressColor,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                Text(
                  progress >= 1
                      ? TTexts.goalAchieved.tr
                      : progress > 0.7
                      ? TTexts.almostThere.tr
                      : TTexts.keepGoaing.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You've completed $percentage% of your goal",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
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


class StepsWeeklyChart extends StatelessWidget {
  const StepsWeeklyChart({
    super.key,
    required this.controller,
    required this.context,
  });

  final HealthController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
  final weeklySteps = controller.getCurrentWeekSteps();
  final isDark  = THelperFunctions.isDarkMode(context);
  return TRoundedContainer(
    padding: EdgeInsets.all(TSizes.sm),
    backgroundColor: isDark?TColors.dark:TColors.light,
    height: 280,
    child: SfCartesianChart(
      title: ChartTitle(
        alignment: ChartAlignment.near,
        text: "Weekly Overview",
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:isDark?TColors.textWhite :TColors.textPrimary,
            ),
      ),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      primaryYAxis: NumericAxis(
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        borderColor: Colors.purple,
        borderWidth: 1,
        color: Colors.white,
        textStyle: const TextStyle(color: Colors.black),
      ),
      series: <CartesianSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: weeklySteps,
          xValueMapper: (data, _) => data["day"],
          yValueMapper: (data, _) => data["steps"],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ],
    ),
  );
}
}
