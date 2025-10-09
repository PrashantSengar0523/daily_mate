
// import 'package:big_bang_crackers/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../containers/rounded_container.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget appBarWidget;
  final bool showBackArrow;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool? showSearchWidget;

  const TAppBar({
    super.key,
    required this.appBarWidget,
    this.showBackArrow = false,
    this.onBackPressed,
    this.actions,
    this.showSearchWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    final darkmode = THelperFunctions.isDarkMode(context);
    final textStyle = Theme.of(context).textTheme;

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24), // <-- adjust as needed
          bottomRight: Radius.circular(24),
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkmode ? TColors.dark : TColors.lightGrey,
          elevation: 6,
          shadowColor: TColors.black.withOpacity(0.2),
          titleSpacing: 12,
          title: Column(
            children: [
              Row(
                children: [
                  appBarWidget,
                  const Spacer(),
                  ...actions ??
                      [
                        // IconButton(
                        //   icon: Icon(Iconsax.notification, color: TColors.white),
                        //   onPressed: () {},
                        // ),
                        // SizedBox(width: TSizes.spaceBtwItems / 4),
                        // IconButton(
                        //   icon: Icon(Iconsax.heart, color: TColors.white),
                        //   onPressed: () {
                        //     Get.to(()=>WishlistView());
                        //   },
                        // ),
                      ],
                ],
              ),
              SizedBox(height: TSizes.spaceBtwItems),
              if (showSearchWidget ?? false) ...[
                /// Search Bar
                TRoundedContainer(
                  onTap: () {
                   
                  },
                  margin: EdgeInsets.only(
                    top: TSizes.md,
                    left: TSizes.sm,
                    right: TSizes.sm,
                  ),
                  height: 45,
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: TSizes.md,
                  ),
                  showBorder: true,
                  showShadow: false,
                  backgroundColor: darkmode ? TColors.dark : TColors.light,
                  radius: 12,
                  borderColor: darkmode ? TColors.darkGrey : TColors.darkerGrey,
                  child: Row(
                    children: [
                      // Hint Text
                      Text(
                        "Search ...",
                        style: textStyle.labelMedium?.copyWith(
                          color:
                              darkmode
                                  ? TColors.textWhite
                                  : TColors.textPrimary,
                          fontSize: TSizes.fontSizeSm,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Iconsax.search_normal,
                        color: TColors.primary,
                        size: TSizes.lg,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class THomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackArrow;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const THomeAppBar({
    super.key,
    this.showBackArrow = false,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = THelperFunctions.isDarkMode(context);
    final textTheme = Theme.of(context).textTheme;

    return PreferredSize(
      preferredSize: preferredSize,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // gradient ke liye transparent
          statusBarIconBrightness: Brightness.light, // icons white
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          decoration: BoxDecoration(
            color: TColors.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color:isDark? Colors.white.withOpacity(0.08):Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// App icon ya back button
              if (showBackArrow)
                IconButton(
                  icon: const Icon(Icons.ac_unit_rounded, color: Colors.white,size: TSizes.iconLg,),
                  onPressed: onBackPressed,
                )
              else
                Image.asset(
                  "assets/icons/app_icon.png", // yaha apna icon dalna
                  height: 40,
                  width: 40,
                ),
        
              const SizedBox(width: 12),
        
              /// Title + Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TTexts.appName.tr,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    THelperFunctions.getGreetMessage(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
        
              const Spacer(),
        
              /// Actions
              ...?actions,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
