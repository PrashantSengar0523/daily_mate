import 'dart:io';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/greet_generator_controller.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CanvaStyleEditView extends StatefulWidget {
  const CanvaStyleEditView({super.key});

  @override
  State<CanvaStyleEditView> createState() => _CanvaStyleEditViewState();
}

class _CanvaStyleEditViewState extends State<CanvaStyleEditView> {
  final GreetCardController controller = Get.put(GreetCardController());
  final GlobalKey cardKey = GlobalKey();
  final TextEditingController textController = TextEditingController();

  int selectedTabIndex = 0; // 0: Templates, 1: Text, 2: Images, 3: Background

  @override
  Widget build(BuildContext context) {
    final textstyle = Theme.of(context).textTheme;
    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              "Modify card",
              style: textstyle.headlineSmall?.copyWith(
                color: TColors.textWhite,
              ),
            ),
            Spacer(),
            // InkWell(
            //   onTap: () async{
            //     await controller.saveCard(cardKey);
            //   },
            //   child: Icon(Icons.download_rounded, color: TColors.textWhite)),
            // SizedBox(width: TSizes.spaceBtwItems),
            InkWell(
              onTap: () async{
                await controller.shareCard(cardKey);
              },
              child: Icon(Icons.share, color: TColors.textWhite)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Canvas Area
          // Expanded(
          //   flex: 2,
          //   child:           ),
          Container(
            margin: EdgeInsets.symmetric(vertical: TSizes.sm),
            // color: const Color(0xFF2d2d2d),
            child: Center(child: _buildCardPreview()),
          ),

          // Tools Panel
          Container(
            height: 240,
            decoration: BoxDecoration(
              // border: Border(
              //   top: BorderSide(
              //     color: isDark ? TColors.darkGrey : TColors.grey,
              //   ),
              // ),
            ),
            child: Column(
              children: [_buildTabBar(), Expanded(child: _buildTabContent())],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    return RepaintBoundary(
      key: cardKey,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.3),
          //     blurRadius: 20,
          //     offset: const Offset(0, 10),
          //   ),
          // ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background
              _buildBackground(),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    _buildTextElement(
                      controller.festivalElement,
                      EditingMode.festival,
                    ),
                    _buildTextElement(
                      controller.messageElement,
                      EditingMode.message,
                    ),
                    if (controller.nameElement.text.isNotEmpty)
                      _buildTextElement(
                        controller.nameElement,
                        EditingMode.name,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (controller.customBackgroundPath != null) {
      return Image.file(
        File(controller.customBackgroundPath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fill,
      );
    }
    return Image.asset(
      controller.currentBackground,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
    );
  }

  Widget _buildTextElement(TextElement element, EditingMode mode) {
    return Positioned(
      left: element.x,
      top: element.y,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (controller.currentEditingMode == mode && element.isSelected) {
              controller.selectElement(EditingMode.none); // unselect
            } else {
              controller.selectElement(mode); // select
            }
          });
        },

        onPanUpdate: (details) {
          setState(() {
            controller.updateElementPosition(
              mode,
              details.delta.dx,
              details.delta.dy,
            );
          });
        },
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(4),
          decoration:
              element.isSelected
                  ? BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  )
                  : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260), // safe width
            child: Text(
              element.text,
              // softWrap: true,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: GoogleFonts.getFont(
                element.fontFamily,
                fontSize: element.fontSize,
                fontWeight: element.fontWeight,
                color: element.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final textstyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);
    final tabs = ['Templates', 'Text', 'Background'];
    final icons = [
      Icons.style,
      Icons.text_fields,
      Icons.image,
      Icons.wallpaper,
    ];

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTabIndex = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? TColors.primary : TColors.textSecondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      icons[index],
                      color:
                          isSelected
                              ? Colors.white
                              : isDark
                              ? TColors.grey
                              : TColors.grey,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabs[index],
                      style: textstyle.bodySmall?.copyWith(
                        color:
                            isSelected
                                ? Colors.white
                                : isDark
                                ? TColors.grey
                                : TColors.grey,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildTemplatesTab();
      case 1:
        return _buildTextTab();
      case 2:
        return _buildBackgroundTab();
      default:
        return Container();
    }
  }

  Widget _buildTemplatesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: controller.backgrounds.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.changeBackground(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            controller.backgroundIndex == index
                                ? TColors.primary
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        controller.backgrounds[index],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTab() {
    final textstyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    final selectedElement =
        controller.currentEditingMode == EditingMode.festival
            ? controller.festivalElement
            : controller.currentEditingMode == EditingMode.message
            ? controller.messageElement
            : controller.currentEditingMode == EditingMode.name
            ? controller.nameElement
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Text Selection
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildTextSelectionButton(
            //         "Festival",
            //         EditingMode.festival,
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: _buildTextSelectionButton(
            //         "Message",
            //         EditingMode.message,
            //       ),
            //     ),
            //     const SizedBox(width: 8),
            //     Expanded(
            //       child: _buildTextSelectionButton(
            //         "Name",
            //         EditingMode.name,
            //       ),
            //     ),
            //   ],
            // ),
            if (selectedElement != null) ...[
              // const SizedBox(height: 16),

              // // Text Input
              // TTextField(
              //   controller: textController..text = selectedElement.text,
              //   onChanged: (value) {
              //     setState(() {
              //       controller.updateSelectedTextElement(text: value);
              //     });
              //   },
              //   hintText: "Enter text",
              // ),

              // const SizedBox(height: 16),

              // Font Size
              _buildSliderControl(
                "Font Size",
                selectedElement.fontSize,
                10.0,
                40.0,
                (value) {
                  setState(() {
                    controller.updateSelectedTextElement(fontSize: value);
                  });
                },
              ),

              const SizedBox(height: 16),

              // Font Family
              Text(
                "Font Family",
                style: textstyle.bodyLarge?.copyWith(
                  color: isDark ? TColors.textWhite : TColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableFonts.length,
                  itemBuilder: (context, index) {
                    final font = availableFonts[index];
                    final isSelected = selectedElement.fontFamily == font;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.updateSelectedTextElement(
                            fontFamily: font,
                          );
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF4285f4)
                                  : const Color(0xFF2d2d2d),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            font,
                            style: GoogleFonts.getFont(
                              font,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Colors
              Text(
                "Colors",
                style: textstyle.bodyLarge?.copyWith(
                  color: isDark ? TColors.textWhite : TColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    availableColors.map((color) {
                      final isSelected = selectedElement.color == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            controller.updateSelectedTextElement(color: color);
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? isDark
                                          ? TColors.light
                                          : TColors.dark
                                      : Colors.grey.shade600,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _buildTextSelectionButton(String label, EditingMode mode) {
  //   final isSelected = controller.currentEditingMode == mode;
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         controller.selectElement(mode);
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 12),
  //       decoration: BoxDecoration(
  //         color: isSelected ? const Color(0xFF4285f4) : const Color(0xFF2d2d2d),
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(
  //           color: isSelected ? const Color(0xFF4285f4) : Colors.grey.shade600,
  //         ),
  //       ),
  //       child: Center(
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             color: isSelected ? Colors.white : Colors.grey.shade300,
  //             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBackgroundTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await controller.setCustomBackground();
                setState(() {});
              },
              child: Column(
                children: [
                  Text("Add Custom Background"),
                  SizedBox(height: TSizes.spaceBtwItems),
                  Icon(Icons.add_box, size: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final textstyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textstyle.bodyLarge?.copyWith(
                color: isDark ? TColors.textWhite : TColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TColors.secondary,
            inactiveTrackColor: Colors.grey.shade700,
            thumbColor: TColors.secondary,
            overlayColor: TColors.secondary.withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
