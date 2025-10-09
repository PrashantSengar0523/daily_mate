// ignore_for_file: deprecated_member_use

import 'package:daily_mate/features/controllers/quick_tool_controller/greet_generator_controller.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/edit_greet_card_view.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/utils/constants/colors.dart';

class GreetGeneratorView extends StatefulWidget {
  const GreetGeneratorView({super.key});

  @override
  State<GreetGeneratorView> createState() => _GreetGeneratorViewState();
}

class _GreetGeneratorViewState extends State<GreetGeneratorView> {
  final GlobalKey previewKey = GlobalKey();

  final TextEditingController festivalController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final GreetCardController controller = Get.put(GreetCardController());

  Widget buildCustomGreetingCard() {
    if (controller.selectedFestival.isEmpty) return Container();

    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Image.asset(
              controller.currentBackground,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),
            
            // Gradient Overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // Colors.black.withOpacity(0.2),
                    // Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Content
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Festival Header
                  Column(
                    children: [
                      Text(
                        "HAPPY\n${controller.displayFestival.toUpperCase()}",
                        style: GoogleFonts.pacifico(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.deepOrange,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                                       
                  // Message
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      controller.displayMessage,
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                        letterSpacing: 1,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Name (if provided)
                  if (nameController.text.trim().isNotEmpty)
                    Text(
                        "From ${nameController.text.trim()}",
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TColors.error,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    festivalController.dispose();
    messageController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              "Festival Greeting Generator",
              style: textStyle.titleMedium?.copyWith(color: TColors.textWhite),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Custom Greeting Section
            TRoundedContainer(
              backgroundColor: isDark ? TColors.darkerGrey : TColors.light,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Create Custom Greeting",
                        style: textStyle.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.defaultSpace),
                   TTextField(
                          hintText: 'Festival Name ',
                          controller: festivalController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\n')),
                            WordLimitFormatter(5),
                          ],
                        ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                   TTextField(
                          hintText: 'Your Name',
                          controller: nameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\n')),
                            WordLimitFormatter(3),
                          ],
                        ),
                 
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  
                  // Custom Message
                  TTextField(
                    hintText: 'Custom Message',
                    controller: messageController,
                    maxLines: 3,
                    inputFormatters: [WordLimitFormatter(20)],
                  ),

                  const SizedBox(height: 20),
                  
                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 20),
                      label: const Text(
                        "Create Greeting Card",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (festivalController.text.trim().isEmpty) {
                          Get.snackbar(
                            "Required",
                            "Please enter a festival name",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        
                        setState(() {
                          controller.updateCardData(
                            festivalController.text.trim(),
                            messageController.text.trim(),
                            nameController.text.trim(),
                          );
                        });
                        Get.to(()=>CanvaStyleEditView());
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              margin: const EdgeInsets.symmetric(vertical: 32),
              child: Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
            ),
            
            // Quick Festival Cards Section
            Row(
              children: [
                Text(
                  "Quick Cards",
                  style: textStyle.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // ye firebase se aayenge
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: controller.existingCards.length,
              itemBuilder: (context, index) {
                final asset = controller.existingCards[index];
                return Card(
                  elevation: 6,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      try {
                        await controller.shareExistingCard(asset);
                      } catch (e) {
                        Get.snackbar("Error", "Failed to share card");
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(asset, fit: BoxFit.cover),
                        
                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        
                        // Share Button
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.share,
                              color: TColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        
                        // Tap to share indicator
                        const Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            "Tap to Share",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class WordLimitFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitFormatter(this.maxWords);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.trim().split(RegExp(r'\s+'));
    if (words.length > maxWords && newValue.text.trim().isNotEmpty) {
      return oldValue;
    }
    return newValue;
  }
}