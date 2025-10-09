// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:daily_mate/common/widgets/appbar/custom_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/features/controllers/holiday_controller.dart';
import 'package:daily_mate/features/controllers/home_controller.dart';
import 'package:daily_mate/features/controllers/quote_controller.dart';
import 'package:daily_mate/features/controllers/word_controller.dart';
import 'package:daily_mate/features/views/home/today_in_history_view.dart';
import 'package:daily_mate/features/views/home/weather_detail_view.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.put(
    HomeController(),
    tag: "HomeController",
  );
  final HolidayController holidaycontroller = Get.put(
    HolidayController(),
    tag: "HolidayController",
  );
  final QuoteController quoteController = Get.put(
    QuoteController(),
    tag: "QuoteController",
  );

  final WordController wordController = Get.put(
    WordController(),
    tag: "WordController",
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? TColors.dark : TColors.light,
      appBar: THomeAppBar(showBackArrow: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final showMask = controller.maskSuggestion.value;
              final showUmbrella = controller.umbrellaSuggestion.value;

              if (!showMask && !showUmbrella) return const SizedBox();

              return Row(
                children: [
                  if (showMask)
                    Expanded(
                      child: TRoundedContainer(
                        radius: 11,
                        padding: EdgeInsets.all(TSizes.sm),
                        backgroundColor:
                            isDark
                                ? Colors.redAccent.withOpacity(0.2)
                                : Colors.redAccent.withOpacity(0.1),
                        borderColor: Colors.redAccent,
                        showShadow: false,
                        showBorder: true,
                        child: Row(
                          children: [
                            Icon(Icons.masks, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text(
                              TTexts.wearMask.tr,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark ? Colors.red[200] : Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (showMask && showUmbrella) const SizedBox(width: 12),

                  if (showUmbrella)
                    Expanded(
                      child: TRoundedContainer(
                        radius: 11,
                        padding: EdgeInsets.all(TSizes.sm),
                        backgroundColor:
                            isDark
                                ? Colors.blueAccent.withOpacity(0.2)
                                : Colors.blueAccent.withOpacity(0.1),
                        borderColor: Colors.blueAccent,
                        showShadow: false,
                        showBorder: true,
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.umbrella_fill,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              TTexts.carryUmbrella.tr,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.blue[200]
                                        : Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }),

            const SizedBox(height: 16),

            Obx(() {
              final weatherData = controller.aqiWeather.value;

              if (weatherData == null) {
                return weatherCard(
                  wind: storageService.read(wind) ?? "0",
                  humidity: storageService.read(humidity) ?? "0",
                  temperature: storageService.read(temp) ?? "",
                  condition: THelperFunctions.getWeatherCondition(
                    storageService.read(condition) ?? "-",
                  ),
                  location: storageService.read(city) ?? "-",
                  aqi: storageService.read(aqi) ?? "0",
                  pm25: storageService.read(pm25) ?? "0",
                  pm10: storageService.read(pm10) ?? "0",
                  isDark: isDark,
                );
              }

              return weatherCard(
                wind: weatherData.wind.toStringAsFixed(0),
                humidity: weatherData.humidity.toString(),
                temperature: weatherData.temperature.toStringAsFixed(0),
                condition: THelperFunctions.getWeatherCondition(
                  weatherData.condition,
                ),
                location: weatherData.city,
                aqi: weatherData.aqi.toString(),
                pm25: weatherData.pm25.toString(),
                pm10: weatherData.pm10.toString(),
                isDark: isDark,
              );
            }),

            const SizedBox(height: 16),
            Obx(() {
              if (controller.todayForecast.isEmpty) return SizedBox();
              final forecastList = controller.todayForecast;
              final fiveDaysForecastList = controller.fiveDayForecast;
              return TodaysWeatherForecast(
                textStyle: textTheme,
                isDark: isDark,
                forecastList: forecastList,
                fiveDaysForecastList: fiveDaysForecastList,
              );
            }),

            const SizedBox(height: 16),

            Obx(() {
              final holiday = holidaycontroller.todayHoliday.value;
              final quote = quoteController.quoteOfTheDay.value;
              final isQuoteLoading = quoteController.isLoading.value;

              if (holiday == null) {
                // ❌ No festival → Show only Quote card
                return quoteCard(isDark, isQuoteLoading ? "-" : quote);
              } else {
                // ✅ Festival available → Show both cards
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: festivalCard(
                          isDark: isDark,
                          festival:
                              holiday
                                  .name, // holiday?.name ki jagah direct holiday.name
                          day: DateFormat('EEEE').format(DateTime.now()),
                          date: DateFormat(
                            'dd MMM yyyy',
                          ).format(DateTime.now()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            isQuoteLoading
                                ? SizedBox()
                                : quoteCard(isDark, quote),
                      ),
                    ],
                  ),
                );
              }
            }),
            const SizedBox(height: 20),
            Obx(() {
              if (wordController.isLoading.value) {
                return Container();
              }
              if (wordController.hasError.value) {
                return Container();
              }
              return wordCard(
                isDark: isDark,
                word: wordController.word.value,
                meaning: wordController.meaning.value,
                sentence: wordController.example.value,
              );
            }),

            const SizedBox(height: 20),
            TRoundedContainer(
              onTap: () => Get.to(TodayInHistoryView()),
              backgroundColor:
                  isDark
                      ? Colors.teal.shade800.withOpacity(
                        0.6,
                      ) // dark mode: rich teal
                      : Colors.teal.shade100.withOpacity(
                        0.5,
                      ), // light mode: soft teal
              child: Row(
                children: [
                  Text(
                    "Today in History",
                    style: textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.cyanAccent : Colors.teal.shade900,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: TSizes.iconMd / 1.1,
                    color: isDark ? Colors.cyanAccent : Colors.teal.shade900,
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            // TRoundedContainer(
            //   onTap: () => Get.to(const HoroscopeView()),
            //   backgroundColor:
            //       isDark
            //           ? Colors.deepPurple.shade700.withOpacity(
            //             0.7,
            //           ) // Dark mode: rich mystic purple
            //           : Colors.deepPurpleAccent.withOpacity(
            //             0.3,
            //           ), // Light mode: soft elegant purple
            //   child: Row(
            //     children: [
            //       Text(
            //         "Check Horoscope",
            //         style: textTheme.titleMedium?.copyWith(
            //           color:
            //               isDark
            //                   ? Colors.purpleAccent
            //                   : Colors.deepPurple.shade900,
            //         ),
            //       ),
            //       const Spacer(),
            //       Icon(
            //         Icons.arrow_forward_ios_rounded,
            //         size: TSizes.iconMd / 1.1,
            //         color:
            //             isDark
            //                 ? Colors.purpleAccent
            //                 : Colors.deepPurple.shade900,
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Hourly forecast horizontal list

  Widget weatherCard({
    required String temperature,
    required String condition,
    required String location,
    required String aqi,
    required String pm25,
    required String pm10,
    required String humidity,
    required String wind,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors:
                  isDark
                      ? [
                        TColors.warning.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ]
                      : [
                        TColors.warning.withOpacity(0.4),
                        TColors.white.withOpacity(0.2),
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Top Row (Icon + Weather condition | Temp + Humidity/Wind)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Weather icon + condition
                  Column(
                    children: [
                      Text(
                        "$temperature°",
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        condition,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? TColors.textWhite : TColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  // Right: Temperature + Humidity & Wind
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "$humidity%",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  TTexts.humidity.tr,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "$wind km/h",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  TTexts.wind.tr,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _aqiChip("${TTexts.aqi.tr}: $aqi", isDark, Colors.blue),
                  _aqiChip("${TTexts.pm25.tr}: $pm25", isDark, Colors.green),
                  _aqiChip("${TTexts.pm10.tr}: $pm10", isDark, Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aqiChip(String label, bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget festivalCard({
    required bool isDark,
    required String? festival, // null allowed
    required String day,
    required String date,
  }) {
    final displayFestival =
        (festival == null || festival.isEmpty)
            ? "No Festival or Holiday"
            : festival;

    final bgGradient =
        isDark
            ? [
              Colors.deepOrange.withOpacity(0.25),
              Colors.redAccent.withOpacity(0.15),
            ]
            : [Colors.orange.withOpacity(0.25), Colors.yellow.withOpacity(0.2)];

    final textSecondary = isDark ? Colors.white70 : Colors.black54;
    final festivalTextColor =
        isDark ? Colors.orangeAccent.shade200 : Colors.orange.shade900;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${TTexts.today.tr}🎊",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayFestival,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: festivalTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "$day, $date",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteCard(bool isDark, String quote) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    Colors.indigo.withOpacity(0.25),
                    Colors.deepPurple.withOpacity(0.15),
                  ]
                  : [
                    Colors.blueAccent.withOpacity(0.25),
                    Colors.lightBlue.withOpacity(0.2),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Quote of the Day",
                style: GoogleFonts.poppins(
                  fontSize: TSizes.fontSizeMd,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          Center(
            child: Text(
              "“$quote”",
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget wordCard({
    required bool isDark,
    required String word,
    required String meaning,
    required String sentence,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    Colors.deepPurple.shade700.withOpacity(0.6),
                    Colors.indigo.shade600.withOpacity(0.5),
                  ]
                  : [
                    Colors.blue.shade200.withOpacity(0.4),
                    Colors.cyan.shade100.withOpacity(0.3),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.35)
                    : Colors.blueAccent.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title
          Text(
            "Word of the Day",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 English Word
          Text(
            word.capitalizeFirst.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.amberAccent : Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 English Meaning
          Text(
            meaning,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Example Sentence
          Text(
            "✦ $sentence",
            style: GoogleFonts.lora(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysWeatherForecast extends StatelessWidget {
  const TodaysWeatherForecast({
    super.key,
    required this.textStyle,
    required this.isDark,
    required this.forecastList,
    required this.fiveDaysForecastList,
    this.routeName,
  });

  final TextTheme textStyle;
  final bool isDark;
  final List<Map<String, dynamic>> forecastList;
  final List<Map<String, dynamic>> fiveDaysForecastList;
  final String? routeName;

  @override
  Widget build(BuildContext context) {
    if (forecastList.isEmpty) return SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(20),
            // gradient: LinearGradient(
            //   colors:
            //       isDark
            //           ? [
            //             Colors.deepPurple.withOpacity(0.25),
            //             Colors.indigo.withOpacity(0.15),
            //           ]
            //           : [
            //             Colors.lightBlue.withOpacity(0.25),
            //             Colors.cyan.withOpacity(0.15),
            //           ],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
            // border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Text(
                    TTexts.todaysForecast.tr,
                    style: GoogleFonts.poppins(
                      fontSize: TSizes.fontSizeMd / 1.1,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Spacer(),
                  if (routeName != "weatherDetail")
                    InkWell(
                      onTap: () {
                        Get.to(
                          () => WeatherDetailView(
                            forecastList: forecastList,
                            fiveDaysForecastList: fiveDaysForecastList,
                          ),
                        );
                      },
                      child: Text(
                        "${TTexts.nextFiveDays.tr} >",
                        style: textStyle.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? TColors.textWhite : Colors.lightBlue,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Hourly scroll
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecastList.length.clamp(
                    0,
                    12,
                  ), // limit to next 12 entries
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final hourData = forecastList[index];
                    final dateTime = DateTime.parse(hourData['dt_txt']);
                    final temp = (hourData['main']['temp'] as num)
                        .toStringAsFixed(0);
                    final condition =
                        (hourData['weather'][0]['description'] as String);
                    final iconUrl = THelperFunctions.getWeatherIcon(condition);

                    return Container(
                      width: 70,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.white10
                                : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('ha').format(dateTime),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Image.asset(iconUrl, height: 20, width: 20),

                          const SizedBox(height: 4),
                          Text(
                            "$temp°",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
