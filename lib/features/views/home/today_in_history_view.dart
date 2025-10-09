// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/loaders/circular_loader.dart';
import 'package:daily_mate/common/widgets/view_widgets/t_empty_widget.dart';
import 'package:daily_mate/common/widgets/view_widgets/t_error_widget.dart';
import 'package:daily_mate/features/controllers/today_in_history_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TodayInHistoryView extends StatelessWidget {
  TodayInHistoryView({super.key});

  final TodayHistoryController controller = Get.put(TodayHistoryController());

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: [
            Text(
              "History Events",
              style: textTheme.headlineSmall?.copyWith(
                color: TColors.textWhite,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const TCircularLoader();
          }
          if (controller.hasError.value) {
            return TErrorWidget(onRetry: () => controller.fetchTodayHistory());
          }
          if (controller.events.isEmpty) {
            return TEmptyWidget(message: "No events found");
          }

          return ListView.separated(
            itemCount: controller.events.length,
            separatorBuilder:
                (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              final event = controller.events[index];
              return ShareableTodayInHistoryCard(
                year: event['year'].toString(),
                text: event['text'],
              );
            },
          );
        }),
      ),
    );
  }
}

class ShareableTodayInHistoryCard extends StatelessWidget {
  final String year;
  final String text;

  ShareableTodayInHistoryCard({
    super.key,
    required this.year,
    required this.text,
  });

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
      final file = File('${tempDir.path}/history_event_card_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      print("Error sharing card: $e");
      // Optional: Show snackbar or dialog to user
      Get.snackbar(
        'Error',
        'Failed to share. Please try again.',
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
                child: TodayInHistoryCard(
                  year: year,
                  text: text,
                  showButtons: false,
                ),
              ),
            ),
          ),
        ),
        // Visible card with buttons
        TodayInHistoryCard(
          year: year,
          text: text,
          showButtons: true,
          onShare: _shareCard,
        ),
      ],
    );
  }
}

class TodayInHistoryCard extends StatelessWidget {
  final String year;
  final String text;
  final bool showButtons;
  final VoidCallback? onShare;

  const TodayInHistoryCard({
    super.key,
    required this.year,
    required this.text,
    this.showButtons = true,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    final bgGradient =
        isDark
            ? [
              Colors.teal.shade900.withOpacity(0.85),
              Colors.green.shade800.withOpacity(0.8),
            ]
            : [Colors.green.shade100, Colors.teal.shade50];

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
            text,
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
              Text(
                "Year - $year",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: authorColor,
                ),
              ),
              const Spacer(),
              if (showButtons) ...[
                TRoundedContainer(
                  onTap: onShare,
                  backgroundColor:
                      isDark
                          ? Colors.tealAccent.shade400
                          : Colors.greenAccent.shade400,
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
