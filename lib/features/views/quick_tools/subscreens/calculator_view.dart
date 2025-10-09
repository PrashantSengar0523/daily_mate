import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/calculator_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalculatorView extends StatelessWidget {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    final controller = Get.put(CalculatorController());

    return Scaffold(
      appBar: TCommonAppBar(
        appBarWidget: Text(
          TTexts.calculator.tr,
          style: textTheme.titleMedium?.copyWith(
            color: TColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          /// Display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              color: isDark ? Colors.black : Colors.grey.shade200,
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      controller.expression.value,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.result.value,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Buttons
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final btn = controller.buttons[index];

                  /// Determine button style
                  final isOperator = ["÷", "x", "-", "+", "="].contains(btn);
                  final isFunction = ["AC", "⌫", "+/-", "%"].contains(btn);

                  return GestureDetector(
                    onTap: () => controller.onButtonPressed(btn),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient:
                            isOperator
                                ? LinearGradient(
                                  colors:
                                      isDark
                                          ? [
                                            Colors.deepPurple.shade400,
                                            Colors.deepPurple.shade700,
                                          ]
                                          : [
                                            Colors.orangeAccent.shade200,
                                            Colors.orange.shade400,
                                          ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : isFunction
                                ? LinearGradient(
                                  colors:
                                      isDark
                                          ? [TColors.primary, TColors.primary]
                                          : [TColors.primary, TColors.primary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : LinearGradient(
                                  colors:
                                      isDark
                                          ? [
                                            Colors.blueGrey.shade800,
                                            Colors.blueGrey.shade900,
                                          ]
                                          : [
                                            Colors.white,
                                            Colors.grey.shade100,
                                          ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          btn,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color:
                                isOperator
                                    ? Colors.white
                                    : isFunction
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white70
                                    : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}
