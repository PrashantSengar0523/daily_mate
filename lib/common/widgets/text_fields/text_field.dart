import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';

///============================= TEXT FIELD =====================================///

class TTextField extends StatelessWidget {
  const TTextField({
    super.key,
    this.hintText,
    this.controller,
    this.textInputType,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.words,
    this.focusNode,
    this.enableBorderColor = TColors.grey,
    this.focusBorderColor,
    this.hintTextColor,
    this.autoFocus = false,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines,
  });

  final int? maxLines;
  final int? maxLength;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final Color? hintTextColor;
  final bool autoFocus;
  final bool readOnly;
  final bool enabled;
  final Color? enableBorderColor;
  final Color? focusBorderColor;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final darkmode = THelperFunctions.isDarkMode(context);
    final textStyle = Theme.of(context).textTheme;
    return TextFormField(
      textCapitalization: textCapitalization,
      keyboardType: textInputType,
      controller: controller,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      cursorColor:darkmode?Colors.white: TColors.primary,
      obscureText: obscureText,
      autofocus: autoFocus,
      focusNode: focusNode,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      textInputAction: TextInputAction.next,
      style: textStyle.headlineMedium?.copyWith(
          // color: TColors.textPrimary,
          fontSize: TSizes.fontSizeSm,
          fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText??"Label",
        hintStyle: textStyle.headlineMedium?.copyWith(

            color:hintTextColor??TColors.darkGrey,
            fontSize: TSizes.fontSizeSm,
            fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.transparent, // Light Grey Background
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9.0),
          borderSide: const BorderSide(
            color: TColors.grey,
            width: 1.0,
          ), // Default Light Grey Border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9.0),
          borderSide: BorderSide(
            color: focusBorderColor ?? TColors.primary,
            width: 1.0,
          ), // Primary Color on Focus
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9.0),
          borderSide: BorderSide(
            color: enableBorderColor ?? TColors.grey,
            width: 1.0,
          ), // Light Grey when not focused
        ),
        // disabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(9.0),
        //   borderSide: const BorderSide(
        //       color: TColors.grey, width: 1.0), // Light Grey for Disabled
        // ),
      ),
    );
  }
}

