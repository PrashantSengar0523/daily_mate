import 'package:daily_mate/features/models/track_expense_model.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TrackExpenseController extends GetxController {

  var expenseCategories = <Map<String, dynamic>>[
  {"name": "Food & Dining", "color": Colors.red},
  {"name": "Groceries", "color": Colors.green},
  {"name": "Transport", "color": Colors.blue},
  {"name": "Housing / Rent", "color": Colors.orange},
  {"name": "Utilities", "color": Colors.purple},
  {"name": "Health & Fitness", "color": Colors.teal},
  {"name": "Shopping / Clothing", "color": Colors.pink},
  {"name": "Entertainment", "color": Colors.indigo},
  {"name": "Travel & Vacation", "color": Colors.cyan},
  {"name": "Education", "color": Colors.brown},
  {"name": "Insurance / Investments", "color": Colors.lime},
  {"name": "Other", "color": Colors.grey},
].obs;


  var isLoading = false.obs;
  var totalExpense = 0.0.obs;
  var thisWeekExpense = 0.0.obs;
  var thisMonthExpense = 0.0.obs;

  /// Controllers for Add Expense Dialog
  TextEditingController expenseNameController = TextEditingController();
  TextEditingController expenseAmount = TextEditingController();
  TextEditingController expenseDate = TextEditingController();

  /// List of Expenses
  RxList<TrackExpenseModel> expenses = <TrackExpenseModel>[].obs;

  final String _storageKey = "expenses";

  @override
  void onInit() {
    super.onInit();
    getExpenses();
  }

  /// Add Expense
  Future<void> addExpense() async {
    try {
      isLoading.value = true;

      final expense = TrackExpenseModel(
        name: expenseNameController.text.trim(),
        amount: double.tryParse(expenseAmount.text.trim()) ?? 0,
        date: DateFormat("d MMMM, y").parse(expenseDate.text.trim()),
      );

      expenses.add(expense);

      /// Save to storage
      final expenseList = expenses.map((e) => e.toJson()).toList(); // List<Map>
      await storageService.write(_storageKey, expenseList);

      _calculateTotals();

      /// Clear fields
      expenseNameController.clear();
      expenseAmount.clear();
      expenseDate.clear();
    } catch (e) {
      debugPrint("Error adding expense: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all Expenses from Storage
  void getExpenses() {
    final data = storageService.read(_storageKey);
    if (data != null) {
      expenses.value =
          List<Map<String, dynamic>>.from(
            data,
          ).map((e) => TrackExpenseModel.fromJson(e)).toList();
    }
    _calculateTotals();
  }

  /// Clear all expenses
  void deleteExpenses() async {
    try {
      isLoading.value = true;

      // Remove from storage
      storageService.remove(_storageKey);

      // Clear the list
      expenses.clear();

      // Reset totals
      totalExpense.value = 0.0;
      thisWeekExpense.value = 0.0;
      thisMonthExpense.value = 0.0;
    } catch (e) {
      debugPrint("Error deleting expenses: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete specific expense
  Future<void> deleteExpense(int index) async {
    try {
      isLoading.value = true;

      expenses.removeAt(index);

      // Save back to storage
      final expenseList = expenses.map((e) => e.toJson()).toList();
      await storageService.write(_storageKey, expenseList);

      _calculateTotals();
    } catch (e) {
      debugPrint("Error deleting expense: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Edit expense
  Future<void> editExpense(int index, TrackExpenseModel updatedExpense) async {
    try {
      isLoading.value = true;

      expenses[index] = updatedExpense;

      // Save back to storage
      final expenseList = expenses.map((e) => e.toJson()).toList();
      await storageService.write(_storageKey, expenseList);

      _calculateTotals();
    } catch (e) {
      debugPrint("Error editing expense: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate Total, This Week, This Month
  void _calculateTotals() {
    final now = DateTime.now();

    totalExpense.value = expenses.fold(0.0, (sum, e) => sum + e.amount);

    thisWeekExpense.value = expenses
        .where(
          (e) =>
              e.date.isAfter(now.subtract(Duration(days: now.weekday))) &&
              e.date.isBefore(now.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, e) => sum + e.amount);

    thisMonthExpense.value = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

 Map<String, Map<String, dynamic>> getCurrentMonthCategoryExpenses() {
  final now = DateTime.now();
  final Map<String, double> totals = {};
  double totalSpent = 0;

  for (final exp in expenses) {
    if (exp.date.month == now.month && exp.date.year == now.year) {
      totals[exp.name] = (totals[exp.name] ?? 0) + exp.amount;
      totalSpent += exp.amount;
    }
  }

  // Map with amount, percent, and color
  final Map<String, Map<String, dynamic>> result = {};
  for (final entry in totals.entries) {
    final color = expenseCategories.firstWhere(
      (cat) => cat["name"] == entry.key,
      orElse: () => {"color": Colors.grey},
    )["color"] as Color;

    result[entry.key] = {
      "amount": entry.value,
      "percent": (entry.value / totalSpent) * 100,
      "color": color,
    };
  }

  return result;
}

}
