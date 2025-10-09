
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

class TCommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget appBarWidget;
  final bool showBackArrow;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const TCommonAppBar({
    super.key,
    required this.appBarWidget,
    this.showBackArrow = false,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = THelperFunctions.isDarkMode(context);

    return PreferredSize(
       preferredSize: const Size.fromHeight(60),
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24), // <-- adjust as needed
        bottomRight: Radius.circular(24),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        backgroundColor: TColors.primary,
        shadowColor: isDark?TColors.light.withOpacity(0.12):null,
        titleSpacing: TSizes.spaceBtwItems,
        title: Row(
          children: [
            /// Back Button
            if (showBackArrow) InkWell(
              onTap: () {
                Get.back();
              },
              child: Icon(Icons.arrow_back_rounded,color: TColors.white,)),
      
            /// Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: TSizes.spaceBtwItems),
                child: appBarWidget,
              ),
            ),
      
            /// Actions (Optional)
            if (actions != null && actions!.isNotEmpty)
              ...actions!
            else ...[
            ],
          ],
        ),
      ),)
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
