// ignore_for_file: deprecated_member_use

import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/loaders/circular_loader.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/common/widgets/view_widgets/t_error_widget.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/nearby_locations_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/constants/api_constants.dart';

class NearbyLocationsView extends StatelessWidget {
  NearbyLocationsView({super.key});

  final NearbyPlacesController controller = Get.put(
    NearbyPlacesController(),
    tag: "NearbyPlacesController",
  );

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              "Nearby Locations",
              style: textStyle.headlineSmall?.copyWith(
                color: TColors.textWhite,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Box
            TTextField(
              hintText: 'Search nearby ...',
              onChanged: (val) => controller.searchText.value = val,
            ),
            const SizedBox(height: 20),

            // 📍 Locations List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return TCircularLoader();
                }
                if (controller.hasError.value) {
                  return TErrorWidget(
                    onRetry: () => controller.loadNearbyPlaces(),
                  );
                }

                final filteredPlaces = controller.filterePlaces;
                return ListView.separated(
                  itemCount: filteredPlaces.length,
                  separatorBuilder:
                      (context, index) =>
                          SizedBox(height: TSizes.spaceBtwItems),
                  itemBuilder: (context, index) {
                    final loc = filteredPlaces[index];
                    final cachedLat = storageService.read(currentLat);
                    final cachedLng = storageService.read(currentLong);
                    final distance = controller.calculateDistance(
                      cachedLat,
                      cachedLng,
                      loc.lat,
                      loc.lon,
                    );
                    return TRoundedContainer(
                      onTap: () {
                        openGoogleMaps(loc.lat, loc.lon);
                      },
                      backgroundColor:
                          isDark
                              ? Colors.teal.shade700.withOpacity(0.7)
                              : Colors.teal.shade100.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🔹 Icon
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                isDark
                                    ? Colors.teal.shade900
                                    : Colors.teal.shade400,
                            child: Icon(
                              Iconsax.location5,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),

                          SizedBox(width: TSizes.spaceBtwItems),

                          // 🔹 Name + Distance
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  loc.tags.name ?? '',
                                  style: textStyle.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: TSizes.fontSizeSm,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: TSizes.spaceBtwItems / 3),
                                Text(
                                  "Distance: ${distance.toStringAsFixed(1)} Km",
                                  style: textStyle.bodyMedium?.copyWith(
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🔹 Arrow
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark ? TColors.grey : TColors.iconPrimary,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openGoogleMaps(double destLat, double destLng) async {
  final googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng',
  );

  if (await canLaunchUrl(googleMapsUrl)) {
    // Try to open in Google Maps app
    final launched = await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      // Fallback to browser
      await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.inAppBrowserView,
      );
    }
  } else {
    // Last fallback: browser open karo
    await launchUrl(
      googleMapsUrl,
      mode: LaunchMode.inAppBrowserView,
    );
  }
}

}
