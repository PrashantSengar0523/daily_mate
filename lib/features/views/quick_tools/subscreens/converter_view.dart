// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:ui';
import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/text_fields/t_bottom_sheet_text_field.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/converter_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ConverterView extends StatelessWidget {
  ConverterView({super.key});

  final ConverterController controller = Get.put(ConverterController());
  final TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              TTexts.converter.tr,
              style: textStyle.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.md / 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Category Picker Card
            Obx(
              () => _glassCard(
                isDark,
                lightColors: [
                  const Color(0xFFD6BCFA),
                  Colors.white,
                ], // Lavender
                darkColors: [
                  Colors.deepPurple.shade700,
                  Colors.deepPurple.shade900,
                ],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TTexts.chooseCategory.tr,
                      style: textStyle.titleSmall?.copyWith(
                        color: isDark ? TColors.textWhite : TColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: TSizes.spaceBtwItems),
                    TCustomBottomSheetInput(
                      enableBorderColor: isDark ? Colors.white : Colors.purple,
                      enableSearch: true,
                      controller: TextEditingController(
                        text: controller.selectedCategory.value,
                      ),
                      items: controller.categories,
                      onChanged: controller.updateCategory,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// From → To Units
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _unitCard(
                      context,
                      title: TTexts.from.tr,
                      enableBorderColor: isDark ? Colors.white : Colors.teal,
                      unit: controller.fromUnit.value,
                      items: controller.getUnits(
                        controller.selectedCategory.value,
                      ),
                      onChanged: (val) => controller.fromUnit.value = val,
                      isDark: isDark,
                      lightColors: [
                        const Color(0xFFB2F5EA),
                        Colors.white,
                      ], // Mint
                      darkColors: [Colors.teal.shade700, Colors.teal.shade900],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _swapButton(isDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _unitCard(
                      context,
                      title: TTexts.to.tr,
                      enableBorderColor:
                          isDark ? Colors.white : Colors.orangeAccent,
                      unit: controller.toUnit.value,
                      items: controller.getUnits(
                        controller.selectedCategory.value,
                      ),
                      onChanged: (val) => controller.toUnit.value = val,
                      isDark: isDark,
                      lightColors: [
                        const Color(0xFFFED7D7),
                        Colors.white,
                      ], // Peach
                      darkColors: [
                        Colors.deepOrange.shade700,
                        Colors.deepOrange.shade900,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _glassCard(
              isDark,
              lightColors: [const Color(0xFFBEE3F8), Colors.white], // Sky blue
              darkColors: [Colors.indigo.shade700, Colors.indigo.shade900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Input
                  Text(
                    TTexts.enterValue.tr,
                    style: textStyle.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? TColors.textWhite : TColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TTextField(
                    hintText: TTexts.enterValue.tr,
                    enableBorderColor: isDark ? Colors.white : Colors.indigo,
                    controller: inputController,
                    inputFormatters: [
                      SingleDecimalInputFormatter(),
                    ],
                    textInputType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Convert Button
            TAppButton(
              text: TTexts.convert.tr,
              borderRadius: 24,
              color: TColors.secondary,
              onPressed: () {
                final input = double.tryParse(inputController.text) ?? 0;
                controller.convert(
                  input,
                  controller.fromUnit.value,
                  controller.toUnit.value,
                );
              },
            ),
            const SizedBox(height: 28),

            /// Result
            Obx(() {
              if (controller.result.value.isNotEmpty) {
                return _glassCard(
                  isDark,
                  lightColors: [
                    const Color(0xFFFEFCBF),
                    Colors.white,
                  ], // Yellow tint
                  darkColors: [Colors.amber.shade700, Colors.amber.shade900],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            TTexts.result.tr,
                            style: textStyle.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark
                                      ? TColors.textWhite
                                      : TColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.result.value,
                        style: textStyle.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueAccent,
                          shadows: isDark ? [
                                  ]
                                  : [],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),
          ],
        ),
      ),
    );
  }

  Widget _glassCard(
    bool isDark, {
    required Widget child,
    required List<Color> lightColors,
    required List<Color> darkColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark ? darkColors : lightColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Unit Picker Card
  Widget _unitCard(
    BuildContext context, {
    required String title,
    required Color enableBorderColor,
    required String unit,
    required List<String> items,
    required Function(String) onChanged,
    required bool isDark,
    required List<Color> lightColors,
    required List<Color> darkColors,
  }) {
    final textStyle = Theme.of(context).textTheme;
    return _glassCard(
      isDark,
      lightColors: lightColors,
      darkColors: darkColors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyle.titleSmall?.copyWith(
              color: isDark ? TColors.textWhite : TColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TCustomBottomSheetInput(
            enableSearch: true,
            enableBorderColor: enableBorderColor,
            controller: TextEditingController(text: unit),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// Swap Button
  Widget _swapButton(bool isDark) {
    return InkWell(
      onTap: () {
        controller.swapUnits();
      },
      child: Icon(
        Iconsax.arrow_swap_horizontal,
        size: TSizes.iconSm,
        color:
            isDark
                ? Colors.tealAccent
                : const Color.fromARGB(255, 147, 236, 218),
      ),
    );
  }
}

class SingleDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty string
    if (text.isEmpty) return newValue;

    // Allow only digits and one '.'
    final validPattern = RegExp(r'^\d*\.?\d*$');

    // Reject if multiple '.' present
    if (!validPattern.hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }
}
