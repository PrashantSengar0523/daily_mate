// ignore_for_file: deprecated_member_use, avoid_print, unnecessary_to_list_in_spreads

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/features/controllers/streak_controller.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/features/controllers/quote_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
// import 'package:daily_mate/utils/constants/sizes.dart';

class QuotesView extends StatelessWidget {
  QuotesView({super.key});

  final QuoteController quoteController = Get.put(QuoteController());
  final StreakController streakController = Get.put(StreakController());


  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: 1 + quoteController.topTags.length,
      child: Scaffold(
        appBar: TCommonAppBar(
          showBackArrow: false,
          appBarWidget: Row(
            children: [
              Text(
                TTexts.quotes.tr,
                style: textStyle.titleMedium?.copyWith(
                  color: TColors.textWhite,
                ),
              ),
              Spacer(),
               Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                        "${TTexts.streak.tr} : ${streakController.streak.value}",
                        style: textStyle.bodyMedium?.copyWith(
                          color: TColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: TSizes.spaceBtwItems),

            /// 🔹 Tabs placed in body
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Material(
                color: isDark ? TColors.black : TColors.light,
                child: TabBar(
                  isScrollable: true,
                  padding: EdgeInsets.zero,
                  tabAlignment: TabAlignment.start,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  dividerColor: Colors.transparent,
                  // Text styles
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white70 : Colors.black87,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),

                  // Selected tab background
                  indicator: BoxDecoration(
                    border: Border.all(color:TColors.secondary),
                    borderRadius: BorderRadius.circular(11),
                    color: TColors.secondary, // selected background
                  ),
                  // indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 0.0,

                  // Tabs with border for unselected
                  tabs: [
                    _buildTab("Random", isDark),
                    ...quoteController.topTags.map(
                      (tag) =>
                          _buildTab(tag.capitalizeFirst.toString(), isDark),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔹 Tab content
            Expanded(
              child: Obx(() {
                if (quoteController.allQuotesLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  children: [
                    _buildQuotesList(quoteController.allQuotes),
                    ...quoteController.topTags.map((tag) {
                      final quotes = quoteController.tagWiseQuotes[tag] ?? [];
                      return _buildQuotesList(quotes);
                    }).toList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isDark) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark
                    ? Colors.white24
                    : Colors.black12, // border for unselected
            width: 1.0,
          ),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget _buildQuotesList(List<Map<String, String>> quotes) {
    if (quotes.isEmpty) {
      return const Center(child: Text("No quotes available"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final q = quotes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ShareableQuoteCard(
            quote: q["quote"] ?? "",
            author: q["author"] ?? "",
          ),
        );
      },
    );
  }
}

class ShareableQuoteCard extends StatelessWidget {
  final String quote;
  final String author;

  ShareableQuoteCard({super.key, required this.quote, required this.author});
  final StreakController streakController = Get.find<StreakController>();

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _shareCard() async {
    try {
      // Wait for the widget to be rendered
      await Future.delayed(const Duration(milliseconds: 200));

      final RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        print("Error: RenderRepaintBoundary is null");
        return;
      }

      // Capture the image with high quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        print("Error: Failed to convert image to bytes");
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/quote_card_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles([XFile(file.path)]);
      streakController.onQuoteShared();
      print("Quote shared successfully");
    } catch (e) {
      print("Error sharing card: $e");
      // Optional: Show snackbar or dialog to user
      Get.snackbar(
        'Error',
        'Failed to share quote. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hidden card for sharing (without buttons)
        Positioned(
          left: -10000, // Move offscreen but keep in widget tree
          child: RepaintBoundary(
            key: _globalKey,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width:
                    MediaQuery.of(context).size.width -
                    32, // Match visible card width
                child: QuoteCard(
                  quote: quote,
                  author: author,
                  showButtons: false,
                ),
              ),
            ),
          ),
        ),
        // Visible card with buttons
        QuoteCard(
          quote: quote,
          author: author,
          showButtons: true,
          onShare: _shareCard,
        ),
      ],
    );
  }
}

class QuoteCard extends StatelessWidget {
  final String quote;
  final String author;
  final bool showButtons;
  final VoidCallback? onShare;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.author,
    this.showButtons = true,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient =
        isDark
            ? [
              Colors.purple.shade700.withOpacity(0.9),
              Colors.indigo.shade900.withOpacity(0.85),
            ]
            : [Colors.orange.shade100, Colors.orange.shade50];

    final quoteColor = isDark ? TColors.white : TColors.textPrimary;
    final authorColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "“$quote”",
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: quoteColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  author,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: authorColor,
                  ),
                ),
              ),
              const Spacer(),
              if (showButtons) ...[
                TRoundedContainer(
                  onTap:
                      () => Clipboard.setData(
                        ClipboardData(text: "“$quote”\n- $author"),
                      ),
                  backgroundColor:
                      isDark
                          ? Colors.deepPurpleAccent.shade200
                          : Colors.deepOrangeAccent.shade200,
                  height: 26,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  showShadow: false,
                  child: Row(
                    children: [
                      const Icon(Iconsax.copy5, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        TTexts.copy.tr,
                        style: textStyle.labelSmall?.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TRoundedContainer(
                  onTap: onShare,
                  backgroundColor:
                      isDark
                          ? Colors.purpleAccent.shade200
                          : Colors.orangeAccent.shade200,
                  height: 26,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  showShadow: false,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        TTexts.share.tr,
                        style: textStyle.labelSmall?.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
