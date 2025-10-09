
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';

class TEmptyWidget extends StatelessWidget {
  
  final String? message;

  const TEmptyWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ImageIcon(AssetImage(TImages.appEmpty),size: 36,color: TColors.primary,),
          const SizedBox(height: TSizes.defaultSpace),
          Text(
            message ?? TTexts.noData.tr,
          ),
          
        ],
      ),
    );
  }
}
