// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WeatherDetailView extends StatelessWidget {
  const WeatherDetailView({
    super.key,
    required this.forecastList,
    required this.fiveDaysForecastList,
  });

  final List<Map<String, dynamic>> forecastList;
  final List<Map<String, dynamic>> fiveDaysForecastList;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    // 🟢 Tomorrow's data (index 1 from fiveDaysForecastList)
    final tomorrow =
        fiveDaysForecastList.length > 1 ? fiveDaysForecastList[1] : null;

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              TTexts.nextFiveDays.tr,
              style: textTheme.headlineSmall?.copyWith(
                color: TColors.textWhite,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: TSizes.spaceBtwItems),

            /// 🔹 Tomorrow's Highlight Card
            if (tomorrow != null)
              Container(
                padding: const EdgeInsets.all(TSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [
                              Colors.deepPurple.shade400,
                              Colors.purpleAccent.shade200,
                            ]
                            : [Colors.blue.shade100, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black26
                              : Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Weather icon
                        Image.asset(
                          THelperFunctions.getWeatherIcon(
                            tomorrow['condition'],
                          ),
                          height: 70,
                          width: 70,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TTexts.tomorrow.tr,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              "${tomorrow['condition']} - ${tomorrow['description']}",
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Text(
                              "${tomorrow['max']}° / ${tomorrow['min']}°",
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: TSizes.fontSizeLg * 1.3,
                                color:
                                    isDark
                                        ? Colors.orangeAccent
                                        : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // 🔹 Extra weather info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.air_rounded),
                            Text("7 km/h", style: textTheme.bodyMedium),
                            Text(TTexts.wind.tr, style: textTheme.labelMedium),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.water_drop_rounded),
                            Text("65%", style: textTheme.bodyMedium),
                            Text(TTexts.humidity.tr, style: textTheme.labelMedium),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.remove_red_eye_rounded),
                            Text("10 km", style: textTheme.bodyMedium),
                            Text(TTexts.visibilty.tr, style: textTheme.labelMedium),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: TSizes.defaultSpace),

            /// 🔹 Next 4 days vertical list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  fiveDaysForecastList.length > 1
                      ? fiveDaysForecastList.length - 1
                      : 0,
              separatorBuilder:
                  (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                final item = fiveDaysForecastList[index + 1]; // skip today
                final date = DateTime.parse(item["date"]);
                final formattedDay = DateFormat("EEEE").format(date);

                return TRoundedContainer(
                  padding: EdgeInsets.all(TSizes.md / 1.2),
                  backgroundColor: isDark ? TColors.darkerGrey : TColors.light,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formattedDay, style: textTheme.bodyLarge),
                          SizedBox(height: TSizes.spaceBtwItems / 3),
                          Text(
                            "${item['max']}° / ${item['min']}°",
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        children: [
                          Image.asset(
                            THelperFunctions.getWeatherIcon(item['condition']),
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(height: TSizes.spaceBtwItems / 3),
                          Text(
                            "${item['condition']}",
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
