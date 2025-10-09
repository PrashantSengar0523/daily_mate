import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/constants/colors.dart';

class TAppButton extends StatelessWidget {
  final String text;
  final double? textsize;
  final FontWeight? textWeight;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? elevation;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const TAppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 8.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.elevation = 2.0,
    this.textStyle,
    this.padding, this.textsize, this.textWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: (isDisabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius!),
        child: Container(
          decoration: BoxDecoration(
            color: isDisabled ? TColors.grey : color ?? TColors.primary,
            borderRadius: BorderRadius.circular(borderRadius!),
            boxShadow: [
              if (elevation != null && elevation! > 0)
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: elevation!,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          child: isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) icon!,
                    if (icon != null) const SizedBox(width: 8),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                          fontSize: textsize??14,
                          fontWeight: textWeight??FontWeight.w500,
                          color: textColor ?? TColors.textWhite,
                        ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}



class TAppOutlinedButton extends StatelessWidget {
  final String text;
  final double? textsize;
  final FontWeight? textWeight;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final double? elevation;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const TAppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 8.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.elevation = 2.0,
    this.textStyle,
    this.padding, this.textsize, this.textWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDisabled ? TColors.grey : borderColor ?? TColors.primary,
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: elevation,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor ?? TColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) icon!,
                  if (icon != null) const SizedBox(width: 8),
                  Text(
                    text,
                    style: 
                        GoogleFonts.poppins(
                          fontSize: textsize??14,
                          fontWeight: textWeight??FontWeight.w500,
                          color: textColor ?? TColors.primary,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}






