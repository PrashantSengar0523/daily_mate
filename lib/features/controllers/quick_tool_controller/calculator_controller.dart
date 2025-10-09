import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorController extends GetxController {
  var expression = "".obs;
  var result = "0".obs;

  final buttons = [
    "AC", "⌫", "+/-", "÷",
    "7", "8", "9", "x",
    "4", "5", "6", "-",
    "1", "2", "3", "+",
    "%", "0", ".", "=",
  ];

  final operators = ["+", "-", "x", "÷", "%"];

  void onButtonPressed(String btn) {
    if (btn == "AC") {
      _clear();
    } else if (btn == "⌫") {
      _backspace();
    } else if (btn == "=") {
      _evaluate();
    } else if (btn == "+/-") {
      _toggleSign();
    } else {
      _appendInput(btn);
    }
  }

  void _clear() {
    expression.value = "";
    result.value = "0";
  }

  void _backspace() {
    if (expression.value.isNotEmpty) {
      expression.value =
          expression.value.substring(0, expression.value.length - 1);
    }
  }

  void _toggleSign() {
    if (expression.value.isEmpty) return;

    final regex = RegExp(r'(\d+\.?\d*)$');
    final match = regex.firstMatch(expression.value);
    if (match != null) {
      final numStr = match.group(0)!;
      final numValue = double.tryParse(numStr);
      if (numValue != null) {
        final newValue = -numValue;
        expression.value = expression.value
            .replaceRange(match.start, match.end, newValue.toString());
      }
    }
  }

  void _appendInput(String btn) {
    if (expression.value.isEmpty && operators.contains(btn)) {
      // Don’t start with an operator
      return;
    }

    final lastChar =
        expression.value.isNotEmpty ? expression.value.characters.last : "";

    // Prevent duplicate operators
    if (operators.contains(lastChar) && operators.contains(btn)) {
      return;
    }

    // Prevent multiple dots in a single number
    if (btn == ".") {
      final lastNum = _getLastNumber(expression.value);
      if (lastNum.contains(".")) return;
    }

    expression.value += btn;
  }

  String _getLastNumber(String expr) {
    final regex = RegExp(r'(\d+\.?\d*)$');
    final match = regex.firstMatch(expr);
    return match != null ? match.group(0)! : "";
  }

  void _evaluate() {
    if (expression.value.isEmpty) return;

    try {
      // Replace display symbols
      String exp = expression.value
          .replaceAll("x", "*")
          .replaceAll("÷", "/")
          .replaceAll(" ", ""); // ignore spaces

      // Handle percentage logic
      exp = _handleSmartPercentage(exp);

      // Remove trailing operator if any
      if (operators.any((op) => expression.value.endsWith(op))) {
        exp = exp.substring(0, exp.length - 1);
      }

      Parser p = Parser();
      Expression parsedExp = p.parse(exp);
      ContextModel cm = ContextModel();
      double eval = parsedExp.evaluate(EvaluationType.REAL, cm);

      result.value = _formatResult(eval);
    } catch (e) {
      result.value = "Error";
    }
  }

  /// Smart percentage logic:
  /// 200x10% → 200*(10/100)
  /// 100+10% → 100+(100*10/100)
  /// 100-10% → 100-(100*10/100)
  /// 20% → (20/100)
  String _handleSmartPercentage(String exp) {
    // Clean any spaces before matching
    exp = exp.replaceAll(' ', '');

    // Case 1: handle 200x10%, 100+10%, etc.
    final pattern = RegExp(r'(\d+\.?\d*)([+\-*/])(\d+\.?\d*)%');
    exp = exp.replaceAllMapped(pattern, (match) {
      final base = match.group(1)!;
      final op = match.group(2)!;
      final percent = match.group(3)!;

      if (op == "+" || op == "-") {
        return '$base$op($base*($percent/100))';
      } else {
        return '$base$op($percent/100)';
      }
    });

    // Case 2: single percentage like 12%
    final singlePercent = RegExp(r'(\d+\.?\d*)%');
    exp = exp.replaceAllMapped(singlePercent, (match) {
      final numStr = match.group(1)!;
      return '($numStr/100)';
    });

    return exp;
  }

  String _formatResult(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value
          .toStringAsFixed(4)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }
}
