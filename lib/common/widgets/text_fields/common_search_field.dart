import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';


class CommonSearchTextField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autoFocus;
  final bool showMic;

  const CommonSearchTextField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.controller,
    this.autoFocus = false,
    this.showMic = false,
  });

  @override
  State<CommonSearchTextField> createState() => _CommonSearchTextFieldState();
}

class _CommonSearchTextFieldState extends State<CommonSearchTextField> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          final spokenText = val.recognizedWords;
          if (widget.controller != null) {
            widget.controller!.text = spokenText;
            widget.controller!.selection = TextSelection.fromPosition(
              TextPosition(offset: spokenText.length),
            );
            widget.onChanged?.call(spokenText); // trigger search
          }
        },
        localeId: 'en_IN',
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _handleMicTap() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _handleClear() {
    widget.controller?.clear();
    widget.onClear?.call();
    _focusNode.unfocus(); // 👈 search inactive ho jayega
    setState(() {}); // rebuild to show mic again
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);
    final borderColor = isDark ? TColors.darkGrey : TColors.grey;
    final bgColor =
        isDark ? TColors.darkerGrey.withOpacity(0.3) : TColors.lightGrey.withOpacity(0.2);

    final hasText = widget.controller?.text.isNotEmpty ?? false;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode, // 👈 important
      autofocus: widget.autoFocus,
      onChanged: (text) {
        widget.onChanged?.call(text);
        setState(() {}); // rebuild to toggle suffix icon
      },
      style: textStyle.labelLarge?.copyWith(
        color: isDark ? TColors.textWhite : TColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: TSizes.fontSizeSm,
      ),
      cursorColor: TColors.primary,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: textStyle.labelLarge?.copyWith(
          fontSize: TSizes.fontSizeSm / 1.1,
          color: isDark
              ? TColors.textWhite.withOpacity(0.6)
              : TColors.textPrimary.withOpacity(0.6),
        ),
        filled: true,
        fillColor: bgColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        prefixIcon: const Icon(Iconsax.search_favorite),

        /// Suffix: Clear if text is present, else Mic
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(Icons.clear, color: TColors.primary),
                onPressed: _handleClear,
              )
            : (widget.showMic
                ? IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      color: TColors.primary,
                    ),
                    onPressed: _handleMicTap,
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          borderSide: const BorderSide(color: TColors.primary, width: 1.2),
        ),
      ),
    );
  }
}
