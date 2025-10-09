import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/features/controllers/horoscope_controller.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HoroscopeView extends StatefulWidget {
  const HoroscopeView({super.key});

  @override
  State<HoroscopeView> createState() => _HoroscopeViewState();
}

class _HoroscopeViewState extends State<HoroscopeView> {
  final HoroscopeController controller = Get.put(HoroscopeController());
  String? selectedSign;
  String? horoscope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Text(
          "Daily Horoscope",
          style: theme.headlineSmall?.copyWith(color: TColors.textWhite),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Zodiac Dropdown
            DropdownButtonFormField<String>(
              value: selectedSign,
              hint: const Text("Select your Zodiac Sign"),
              items:
                  zodiacSigns
                      .map(
                        (sign) =>
                            DropdownMenuItem(value: sign, child: Text(sign)),
                      )
                      .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSign = val;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Submit Button
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () async {
                          if (selectedSign == null) {
                            TDialogs.customToast(
                              message: "Please select a zodiac sign",
                            );
                            return;
                          }
                          await controller.getHoroscopeData(selectedSign!);
                        },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Get Horoscope"),
              ),
            ),
            const SizedBox(height: 24),

            Obx(() {
              if (controller.horoscopeResult.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Expanded(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors:
                            isDark
                                ? [
                                  Colors.deepPurple.shade700,
                                  Colors.indigo.shade900,
                                ]
                                : [
                                  Colors.purpleAccent.shade100,
                                  Colors.blue.shade100,
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stars, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  "$selectedSign Horoscope",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(
                              () => Text(
                                controller.horoscopeResult.value,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
