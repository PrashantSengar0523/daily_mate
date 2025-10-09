import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/soothing_music_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SoothingMusicView extends StatelessWidget {
  SoothingMusicView({super.key});

  final controller = Get.put(SoothingMusicController());

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Text(
          "Soothing Music",
          style: textStyle.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: TColors.textWhite,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            Colors.deepPurple.shade700,
                            Colors.deepPurple.shade400,
                          ]
                          : [Colors.blue.shade300, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Relax & Focus 🎧",
                    style: textStyle.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Listen to short sessions of calming music to refresh your mind.",
                    style: textStyle.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            Expanded(
              child: ListView.separated(
                itemCount: controller.tracks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final track = controller.tracks[index];

                  return Obx(() {
                    final isPlaying =
                        controller.currentTrack.value == track["file"] &&
                        controller.isPlaying.value;
                    final durationText =
                        controller.currentTrack.value == track["file"]
                            ? controller.getDurationString(
                              controller.totalDuration.value,
                            )
                            : "";

                    return musicCard(
                      context: context,
                      title: track["title"],
                      subtitle: durationText,
                      image: track["image"],
                      isPlaying: isPlaying,
                      onTap: () => controller.playTrack(track["file"]),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget musicCard({
    required String title,
    required String subtitle,
    required String image,
    required bool isPlaying,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? TColors.darkerGrey : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Album Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
          ),

          const SizedBox(width: 14),

          // 🔹 Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Play / Pause Button
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors:
                      isPlaying
                          ? [Colors.greenAccent, Colors.teal]
                          : [Colors.blueAccent, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow:
                    isPlaying
                        ? [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                        : [],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
