
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../containers/rounded_container.dart';

class TShimmerEffect extends StatelessWidget {
  const TShimmerEffect({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 15,
    this.color,
  }) : super(key: key);

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (dark ? TColors.darkerGrey : TColors.white),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class TCustomShimmer {
  static Widget buildCategoryShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 3),
        Shimmer.fromColors(
          baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildProfileShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular shimmer for profile image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: baseColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          // Column for name and email shimmer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name shimmer
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              // Email shimmer
              Container(
                width: 180,
                height: 12,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildAccountShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24), // TSizes.defaultSpace
          // Profile Header
          Row(
            children: [
              // Circular shimmer for profile image
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),

              // Name and Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 10,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Title Placeholder
          Container(
            width: 150,
            height: 14,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: TSizes.spaceBtwItems),
          // List Items
          ...List.generate(9, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  // Icon shimmer
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text shimmer
                  Expanded(
                    child: Container(
                      // width: MediaQuery.of(context).size.width * 0.6,
                      height: 14,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Widget buildHomeShimmer(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: TSizes.defaultSpace),

             /// Explore Product Banner
            TRoundedContainer(
              width: double.infinity,
              margin: EdgeInsets.only(left: TSizes.lg, right: TSizes.lg),
              height: 120,
              backgroundColor: isDarkMode ? TColors.dark : TColors.light,
              radius: 4,
            ),
            SizedBox(height: TSizes.defaultSpace),

            /// Categories
            TRoundedContainer(
              width: Get.width / 4,
              margin: EdgeInsets.only(left: TSizes.sm),
              height: 20,
              backgroundColor: isDarkMode ? TColors.dark : TColors.light,
              radius: 16,
            ),
            SizedBox(height: TSizes.spaceBtwItems / 1.5),
            SizedBox(
              height: 100, // Slightly increased for better spacing
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                padding: EdgeInsets.only(left: TSizes.sm),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ), // spacing between items
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode ? TColors.dark : TColors.light,
                          ),
                        ),
                        const SizedBox(height: 6), // clean vertical spacing
                        TRoundedContainer(
                          width: Get.width / 7,
                          height: 10,
                          backgroundColor:
                              isDarkMode ? TColors.dark : TColors.light,
                          radius: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
           
            TRoundedContainer(
              width: Get.width / 4,
              margin: EdgeInsets.only(left: TSizes.sm, bottom: TSizes.md),
              height: 20,
              backgroundColor: isDarkMode ? TColors.dark : TColors.light,
              radius: 16,
            ),
            TRoundedContainer(
              margin: EdgeInsets.only(left: TSizes.md, right: TSizes.md),
              height: 350,
              backgroundColor: isDarkMode ? TColors.dark : TColors.light,
              radius: 12,
            ),
            SizedBox(height: TSizes.defaultSpace),
             TRoundedContainer(
              width: double.infinity,
              margin: EdgeInsets.only(left: TSizes.md, right: TSizes.md),
              height: 160,
              backgroundColor: isDarkMode ? TColors.dark : TColors.light,
              radius: 4,
            ),
            SizedBox(height: TSizes.defaultSpace),
            /// Sky Shots
            Padding(
              padding: EdgeInsets.symmetric(horizontal: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TRoundedContainer(
                    width: Get.width / 4,
                    height: 20,
                    backgroundColor: isDarkMode ? TColors.dark : TColors.light,
                    radius: 16,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  GridView.builder(
                    itemCount: 4,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 240,
                        ),
                    itemBuilder: (context, index) {
                      return TRoundedContainer(
                        width: double.infinity,
                        height: 80,
                        backgroundColor:
                            isDarkMode ? TColors.dark : TColors.light,
                        radius: 4,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
