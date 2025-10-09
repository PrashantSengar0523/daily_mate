// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class HealthController extends GetxController {
  // --- Steps Tracking ---
  RxInt steps = 0.obs;
  RxInt baseSteps = 0.obs;
  RxString status = TTexts.stopped.tr.obs;
  RxInt dailyGoal = 1000.obs;
  
  RxString lastSavedDate = ''.obs;
  RxMap<String, int> dailySteps = <String, int>{}.obs;

  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  // --- Sleep Tracking ---
  RxDouble sleepGoal = 8.0.obs;
  RxDouble todaySleep = 0.0.obs;
  RxString lastSleepDate = ''.obs;

  Rx<TimeOfDay?> bedtime = Rx<TimeOfDay?>(null);
  Rx<TimeOfDay?> wakeupTime = Rx<TimeOfDay?>(null);

  RxMap<String, double> dailySleep = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    _checkDayChange();
    _initPedometer();
  }

  void _loadSavedData() {
    /// --- Steps ---
    dailyGoal.value = storageService.read("dailyGoal") ?? 1000;
    steps.value = storageService.read("todaySteps") ?? 0;
    baseSteps.value = storageService.read("baseSteps") ?? 0;
    lastSavedDate.value = storageService.read("lastSavedDate") ?? '';

    final storedSteps = storageService.read("dailySteps") ?? {};
    // ✅ Convert properly with type checking
    dailySteps.value = Map<String, int>.from(
      storedSteps.map((key, value) => MapEntry(key.toString(), (value as num).toInt()))
    );

    /// --- Sleep ---
    sleepGoal.value = storageService.read("sleepGoal")?.toDouble() ?? 8.0;
    todaySleep.value = storageService.read("todaySleep")?.toDouble() ?? 0.0;
    lastSleepDate.value = storageService.read("lastSleepDate") ?? '';

    final storedSleep = storageService.read("dailySleep") ?? {};
    // ✅ Convert properly with type checking
    dailySleep.value = Map<String, double>.from(
      storedSleep.map((key, value) => MapEntry(key.toString(), (value as num).toDouble()))
    );
  }

  /// Check if day has changed and reset accordingly
  void _checkDayChange() {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastSavedDate.value.isNotEmpty && lastSavedDate.value != todayKey) {
      // ✅ CRITICAL: Save yesterday's data BEFORE reset
      _saveYesterdayDataToHistory();
      _resetDailyCounters();
    }
    
    lastSavedDate.value = todayKey;
    storageService.write("lastSavedDate", todayKey);
  }

  /// ✅ NEW: Properly save yesterday's data to history
  void _saveYesterdayDataToHistory() {
    if (lastSavedDate.value.isEmpty) return;
    
    print("📊 Saving yesterday's data for: ${lastSavedDate.value}");
    
    // Save yesterday's steps to history
    if (steps.value > 0) {
      dailySteps[lastSavedDate.value] = steps.value;
      print("  Steps saved: ${steps.value}");
    }
    
    // Save yesterday's sleep to history
    if (todaySleep.value > 0) {
      dailySleep[lastSavedDate.value] = todaySleep.value;
      print("  Sleep saved: ${todaySleep.value} hrs");
    }
    
    // ✅ IMPORTANT: Save the updated maps to storage
    storageService.write("dailySteps", dailySteps.toJson());
    storageService.write("dailySleep", dailySleep.toJson());
    
    print("  Total days in history: ${dailySteps.length}");
  }

  void _resetDailyCounters() {
    print("🔄 Resetting daily counters for new day");
    
    // Reset steps (baseSteps will be updated on next pedometer reading)
    steps.value = 0;
    baseSteps.value = 0;
    storageService.write("todaySteps", 0);
    storageService.write("baseSteps", 0);
    
    // Reset sleep
    todaySleep.value = 0.0;
    bedtime.value = null;
    wakeupTime.value = null;
    storageService.write("todaySleep", 0.0);
    lastSleepDate.value = '';
    storageService.write("lastSleepDate", '');
  }

  // --- Steps ---
  void setGoal(int goal) {
    dailyGoal.value = goal;
    storageService.write("dailyGoal", goal);
  }

  void _saveTodaySteps() {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    
    // Check for day change on every step update
    if (lastSavedDate.value != todayKey) {
      _checkDayChange();
    }

    // ✅ Save current steps value
    storageService.write("todaySteps", steps.value);
    
    // ✅ Also update today's entry in dailySteps (live update)
    dailySteps[todayKey] = steps.value;
    storageService.write("dailySteps", dailySteps.toJson());
  }

  // --- Sleep ---
  void setSleepGoal(double goal) {
    sleepGoal.value = goal;
    storageService.write("sleepGoal", goal);
  }

  void logTodaySleep(double hours) {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    
    todaySleep.value = hours;
    lastSleepDate.value = todayKey;

    // ✅ Save to current day
    storageService.write("todaySleep", todaySleep.value);
    storageService.write("lastSleepDate", todayKey);
    
    // ✅ Also save to history immediately
    dailySleep[todayKey] = todaySleep.value;
    storageService.write("dailySleep", dailySleep.toJson());
    
    print("💤 Sleep logged for $todayKey: $hours hrs");
  }
  
  bool isSleepLoggedToday() {
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    return lastSleepDate.value == todayKey && todaySleep.value > 0;
  }

  // --- Pedometer Init ---
  Future<void> _initPedometer() async {
    var activityStatus = await Permission.activityRecognition.request();
    if (!activityStatus.isGranted) {
      status.value = "Permission Denied";
      return;
    }

    try {
      _stepCountStream = Pedometer.stepCountStream.listen(
        (StepCount event) {
          final todayKey = DateTime.now().toIso8601String().substring(0, 10);
          
          // Check for day change
          if (lastSavedDate.value != todayKey) {
            _checkDayChange();
          }
          
          // Set base steps on first reading of the day
          if (baseSteps.value == 0 && steps.value == 0) {
            baseSteps.value = event.steps;
            storageService.write("baseSteps", baseSteps.value);
          }
          
          // Calculate today's steps = current - base
          steps.value = event.steps - baseSteps.value;
          if (steps.value < 0) steps.value = 0;
          
          _saveTodaySteps();
        },
        onError: (error) {
          status.value = "Step Count Error: $error";
        },
      );

      _pedestrianStatusStream =
          Pedometer.pedestrianStatusStream.listen((PedestrianStatus event) {
        status.value = event.status;
      }, onError: (error) {
        status.value = "Status Error: $error";
      });
    } catch (e) {
      status.value = "Pedometer Init Failed: $e";
    }
  }

  List<Map<String, dynamic>> getCurrentWeekSteps() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      final key = day.toIso8601String().substring(0, 10);
      final todayKey = now.toIso8601String().substring(0, 10);

      return {
        "day": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i],
        "date": key,
        "steps": key == todayKey ? steps.value : (dailySteps[key] ?? 0),
      };
    });
  }
  
  List<Map<String, dynamic>> getCurrentWeekSleep() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      final key = day.toIso8601String().substring(0, 10);
      final todayKey = now.toIso8601String().substring(0, 10);

      return {
        "day": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i],
        "date": key,
        "sleep": key == todayKey ? todaySleep.value : (dailySleep[key] ?? 0.0),
      };
    });
  }

  @override
  void onClose() {
    // ✅ Save current day's data before closing
    final todayKey = DateTime.now().toIso8601String().substring(0, 10);
    
    if (steps.value > 0) {
      dailySteps[todayKey] = steps.value;
      storageService.write("dailySteps", dailySteps.toJson());
    }
    
    if (todaySleep.value > 0) {
      dailySleep[todayKey] = todaySleep.value;
      storageService.write("dailySleep", dailySleep.toJson());
    }
    
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    super.onClose();
  }

  Map<String, dynamic> getWeeklyStatsSummary() {
    final weekSteps = getCurrentWeekSteps();
    final weekSleep = getCurrentWeekSleep();
    
    int totalSteps = 0;
    int daysGoalAchieved = 0;
    double totalSleep = 0.0;
    int daysSleptWell = 0;
    
    for (var day in weekSteps) {
      totalSteps += day['steps'] as int;
      if ((day['steps'] as int) >= dailyGoal.value) {
        daysGoalAchieved++;
      }
    }
    
    for (var day in weekSleep) {
      totalSleep += day['sleep'] as double;
      if ((day['sleep'] as double) >= sleepGoal.value) {
        daysSleptWell++;
      }
    }
    
    return {
      'totalSteps': totalSteps,
      'avgSteps': (totalSteps / 7).round(),
      'daysGoalAchieved': daysGoalAchieved,
      'totalSleep': totalSleep,
      'avgSleep': totalSleep / 7,
      'daysSleptWell': daysSleptWell,
      'weekSteps': weekSteps,
      'weekSleep': weekSleep,
    };
  }
  
  /// ✅ Debug: View all stored data
  void printStoredData() {
    print("\n=== 📊 STORED DATA ===");
    print("Daily Steps History: ${dailySteps.length} days");
    dailySteps.forEach((date, steps) {
      print("  $date: $steps steps");
    });
    
    print("\nDaily Sleep History: ${dailySleep.length} days");
    dailySleep.forEach((date, hours) {
      print("  $date: $hours hrs");
    });
    print("=====================\n");
  }


/// Generate Weekly PDF Report
Future<void> generateWeeklyReport() async {
  try {
    final stats = getWeeklyStatsSummary();
    final pdf = pw.Document();
    final robotoBold = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto-SemiBold.ttf"),);
    
    // Get date range
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    final dateRange = 
        '${startOfWeek.day}/${startOfWeek.month}/${startOfWeek.year} - ${endOfWeek.day}/${endOfWeek.month}/${endOfWeek.year}';
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Weekly Health Report',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  dateRange,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          
          pw.SizedBox(height: 24),
          
          // Steps Section
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'Steps Summary',
                      style: pw.TextStyle(
                        font: robotoBold,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                
                // Steps Stats Grid
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox(
                      'Total Steps',
                      '${stats['totalSteps']}',
                      PdfColors.blue900,
                    ),
                    _buildStatBox(
                      'Avg Steps/Day',
                      '${stats['avgSteps']}',
                      PdfColors.blue700,
                    ),
                    _buildStatBox(
                      'Goals Achieved',
                      '${stats['daysGoalAchieved']}/7',
                      PdfColors.green700,
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 16),
                
                // Daily Steps Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue100,
                      ),
                      children: [
                        _buildTableCell('Day', isHeader: true),
                        _buildTableCell('Steps', isHeader: true),
                        _buildTableCell('Goal', isHeader: true),
                        // _buildTableCell('Status', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...List.generate(7, (i) {
                      final day = stats['weekSteps'][i];
                      final steps = day['steps'] as int;
                      // final achieved = steps >= dailyGoal.value;
                      
                      return pw.TableRow(
                        children: [
                          _buildTableCell(day['day']),
                          _buildTableCell('$steps'),
                          _buildTableCell('${dailyGoal.value}'),
                          // _buildTableCell(
                          //   achieved ? '✓' : '✗',
                          //   color: achieved ? PdfColors.green : PdfColors.red,
                          // ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 24),
          
          // Sleep Section
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.purple50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'Sleep Summary',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                
                // Sleep Stats Grid
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatBox(
                      'Total Sleep',
                      '${stats['totalSleep'].toStringAsFixed(1)} hrs',
                      PdfColors.purple900,
                    ),
                    _buildStatBox(
                      'Avg Sleep/Day',
                      '${stats['avgSleep'].toStringAsFixed(1)} hrs',
                      PdfColors.purple700,
                    ),
                    _buildStatBox(
                      'Goals Achieved',
                      '${stats['daysSleptWell']}/7',
                      PdfColors.green700,
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 16),
                
                // Daily Sleep Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.purple100,
                      ),
                      children: [
                        _buildTableCell('Day', isHeader: true),
                        _buildTableCell('Sleep (hrs)', isHeader: true),
                        _buildTableCell('Goal', isHeader: true),
                        // _buildTableCell('Status', isHeader: true),
                      ],
                    ),
                    // Data rows
                    ...List.generate(7, (i) {
                      final day = stats['weekSleep'][i];
                      final sleep = day['sleep'] as double;
                      // final achieved = sleep >= sleepGoal.value;
                      
                      return pw.TableRow(
                        children: [
                          _buildTableCell(day['day']),
                          _buildTableCell(sleep.toStringAsFixed(1)),
                          _buildTableCell(sleepGoal.value.toStringAsFixed(1)),
                          // _buildTableCell(
                          //   achieved ? '✓' : '✗',
                          //   color: achieved ? PdfColors.green : PdfColors.red,
                          //   font: robotoBold
                          // ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 24),
          
          // Additional Metrics
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Additional Metrics',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                _buildMetricRow(
                  'Calories Burned',
                  '${(stats['totalSteps'] * 0.04).toStringAsFixed(1)} Kcal',
                ),
                _buildMetricRow(
                  'Distance Covered',
                  '${(stats['totalSteps'] * 0.0008).toStringAsFixed(2)} km',
                ),
                _buildMetricRow(
                  'Active Time',
                  '${(stats['totalSteps'] ~/ 100)} minutes',
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 24),
          
          // Footer
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Generated on ${now.day}/${now.month}/${now.year}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
    
    // Save and share PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
    
    // Or save to device
    // final output = await getTemporaryDirectory();
    // final file = File('${output.path}/weekly_health_report.pdf');
    // await file.writeAsBytes(await pdf.save());
    
  } catch (e) {
    print('Error generating PDF: $e');
    Get.snackbar(
      'Error',
      'Failed to generate report: $e',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

// Helper methods for PDF
pw.Widget _buildStatBox(String label, String value, PdfColor color) {
  return pw.Container(
    padding: pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: color, width: 2),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    ),
  );
}

pw.Widget _buildTableCell(
  String text, {
  bool isHeader = false,
  PdfColor? color,
  Font? font,
}) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontSize: isHeader ? 12 : 11,
        color: color ?? PdfColors.black,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _buildMetricRow(String label, String value) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 12)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}