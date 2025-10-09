
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../app_button/t_app_button.dart';

class TErrorWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRetry;
  final String? errorMessage;

  const TErrorWidget({
    super.key,
    this.isLoading = false,
    required this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final darkmode = THelperFunctions.isDarkMode(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_rounded, color:darkmode?TColors.white: TColors.iconPrimary, size: TSizes.iconLg),
          const SizedBox(height: TSizes.defaultSpace),
          Text(
            errorMessage ?? "Something went wrong",
            
          ),
          const SizedBox(height: TSizes.defaultSpace),
          TAppOutlinedButton(
            text: "Retry",
            borderColor: TColors.accent,
            textColor: TColors.accent,
            height: 48,
            width: 120,
            isLoading: isLoading,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
