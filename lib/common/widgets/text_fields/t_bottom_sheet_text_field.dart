
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'text_field.dart';

class TCustomBottomSheetInput extends StatefulWidget {
  final TextEditingController? controller;
  final List<String> items;
  final String hintText;
  final bool enableSearch;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showMessage;
  final String? message;
  final Color? enableBorderColor;
  final Color? focusBorderColor;
  final void Function(String)? onChanged;

  const TCustomBottomSheetInput({
    super.key,
    this.controller,
    required this.items,
    this.hintText = "Tap to select",
    this.enableSearch = false,
    this.enabled = true,
    this.onChanged,
    this.showMessage = false,
    this.message, this.enableBorderColor, this.focusBorderColor, this.validator,
  });

  @override
  State<TCustomBottomSheetInput> createState() =>
      _TCustomBottomSheetInputState();
}

class _TCustomBottomSheetInputState extends State<TCustomBottomSheetInput> {
  final TextEditingController searchController = TextEditingController();
  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void _showBottomSheet(BuildContext context) {
    if (!widget.enabled) return;

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setState) {
      final darkmode = THelperFunctions.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(16),
          height: Get.height * 0.4,
          decoration: BoxDecoration(
            color: darkmode? TColors.dark:TColors.light
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.enableSearch)
                TTextField(
                  controller: searchController,
                  hintText: 'Search...',
                  prefixIcon: const Icon(
                    Iconsax.search_normal,
                    size: TSizes.iconSm,
                  ),
                  onChanged: (query) {
                    setState(() {
                      filteredItems = widget.items
                          .where((item) =>
                              item.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              SizedBox(
                height: TSizes.spaceBtwInputFields,
              ),
              if(widget.showMessage)...[
                Text(widget.message??'  ⚠️  Delivery available only these places',style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: TSizes.fontSizeSm/1.1),),
              ],
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        widget.controller?.text = filteredItems[index];
                        widget.onChanged?.call(filteredItems[index]);
                        Get.back();
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              filteredItems[index],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: TSizes.fontSizeSm,
                              // color: TColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Radio<String>(
                            value: filteredItems[index],
                            groupValue: widget.controller?.text,
                            onChanged: (value) {
                              widget.controller?.text = value ?? '';
                              widget.onChanged?.call(value ?? '');
                              Get.back();
                            },
                            activeColor: TColors.primary,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
        final darkmode = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: AbsorbPointer(
        absorbing:
            true, // Ensures the TTextField stays readOnly in gesture scope
        child: TTextField(
          controller: widget.controller ?? TextEditingController(),
          hintText: widget.hintText,
          readOnly: true,
          enabled: widget.enabled,
          suffixIcon: Icon(Icons.arrow_drop_down_outlined,
              color:darkmode? TColors.grey:TColors.darkGrey),
          enableBorderColor:widget.enableBorderColor?? TColors.grey,
          focusBorderColor: widget.focusBorderColor??TColors.primary,
          textInputType: TextInputType.none, // Prevents keyboard popup
          validator: widget.validator,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TCustomBottomSheetInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      setState(() {
        filteredItems = widget.items;
      });
    }
  }
}
