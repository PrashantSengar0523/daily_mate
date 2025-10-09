import 'package:daily_mate/features/controllers/quick_tool_controller/health_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// 🔹 Weekly Steps Bar Chart
class WeeklyStepsChart extends StatelessWidget {
  final HealthController controller = Get.find();

  WeeklyStepsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final last7Days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final key = DateFormat("yyyy-MM-dd").format(day);
      return {
        "day": DateFormat("E").format(day), // Mon, Tue
        "steps": controller.dailySteps[key] ?? 0,
      };
    });

    final maxSteps = last7Days.map((e) => e["steps"] as int).fold<int>(
        0, (previous, current) => current > previous ? current : previous);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? Colors.blueGrey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Weekly Activity",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxSteps.toDouble() + 1000,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() >= 7)
                            return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              last7Days[value.toInt()]["day"] as String,
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxSteps / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(7, (i) {
                    final steps = last7Days[i]["steps"] as int;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: steps.toDouble(),
                          color: Colors.blueAccent,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Monthly Steps Line Chart
class MonthlyStepsChart extends StatelessWidget {
  final HealthController controller = Get.find();

  MonthlyStepsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    final monthData = List.generate(daysInMonth, (i) {
      final day = DateTime(now.year, now.month, i + 1);
      final key = DateFormat("yyyy-MM-dd").format(day);
      return FlSpot(
        (i + 1).toDouble(),
        (controller.dailySteps[key] ?? 0).toDouble(),
      );
    });

    final maxSteps = monthData.map((e) => e.y).fold<double>(
        0, (previous, current) => current > previous ? current : previous);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? Colors.blueGrey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Monthly Activity",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  maxY: maxSteps + 1000,
                  minY: 0,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 == 0)
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87),
                            );
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxSteps / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: monthData,
                      color: Colors.greenAccent,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.greenAccent.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
