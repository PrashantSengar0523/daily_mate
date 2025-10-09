// ignore_for_file: unused_import

import 'package:daily_mate/features/views/quick_tools/health/health_view.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/calculator_view.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/converter_view.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/greet_genrator_view.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/nearby_locations_view.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/notes_view.dart';
import 'package:daily_mate/features/views/quick_tools/subscreens/soothing_music_view.dart';
import 'package:daily_mate/features/views/settings_/subscreens/track_expense_view.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:torch_light/torch_light.dart';

class QuickToolController extends GetxController {

   final tools = [
  {"icon": Iconsax.calculator, "label": TTexts.calculator.tr, "route": "calculator"},
  {"icon": Iconsax.flash5, "label": TTexts.torch.tr, "route": "torch"},
  {"icon": Iconsax.note, "label": TTexts.notes.tr, "route": "notes"},
  {"icon": Iconsax.money5, "label": TTexts.expenses.tr, "route": "expenses"},
  {"icon": Iconsax.convert5, "label": TTexts.converter.tr, "route": "converter"},
  {"icon": Iconsax.health5, "label": TTexts.health.tr, "route": "health"},
  {"icon": Iconsax.location, "label": TTexts.nearByLocations.tr, "route": "locations"},
  // {"icon": Iconsax.scan, "label": "Qr\nScanner", "route": "qrScanner"},
  {"icon": Icons.generating_tokens_outlined, "label": "Greetings\nGenerator", "route": "greetingsGenrator"},
  {"icon": Iconsax.music5, "label": "Soothing\nMusic", "route": "soothing"},
];
  var isTorchOn = false.obs;

  Future<void> handleToolTap(String route) async {
    switch (route) {
      case "calculator":
        Get.to(() => CalculatorView());
        break;

      case "torch":
        try {
          final available = await TorchLight.isTorchAvailable();
          if (!available) {
            TDialogs.customToast(
                message: "Torch not available", isSucces: false);
            return;
          }

          if (isTorchOn.value) {
            await TorchLight.disableTorch();
            isTorchOn.value = false;
          } else {
            await TorchLight.enableTorch();
            isTorchOn.value = true;
          }
        } catch (e) {
          TDialogs.customToast(message: "Torch error: $e", isSucces: false);
        }
        break;

      case "notes":
        Get.to(() => NotesView());
        break;

      case "expenses":
        Get.to(() => TrackExpenseView());
        break;

       case "converter":
        Get.to(() => ConverterView());
        break;

      case "health":
        Get.to(() => HealthView());
        break;
      case "locations":
        Get.to(() => NearbyLocationsView());
        break;
      //  case "qrScanner":
      //  TDialogs.customToast(message: "We are working");
      //   break;

          case "greetingsGenrator":
      //  TDialogs.customToast(message: "We are working");
        Get.to(() => GreetGeneratorView());
        break;

          case "soothing":
        Get.to(() => SoothingMusicView());
        break;
    }
  }
}
