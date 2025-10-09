// ignore_for_file: deprecated_member_use, unnecessary_null_comparison, avoid_print

import 'dart:io';
import 'dart:ui' as ui;
import 'package:daily_mate/utils/constants/image_strings.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';

enum EditingMode { none, festival, message, name }

class TextElement {
  String text;
  double x, y;
  double fontSize;
  FontWeight fontWeight;
  String fontFamily;
  Color color;
  bool isSelected;

  TextElement({
    required this.text,
    this.x = 50,
    this.y = 50,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'Roboto',
    this.color = Colors.white,
    this.isSelected = false,
  });
}

class ImageElement {
  String? imagePath; // For custom images
  double x, y;
  double width, height;
  bool isSelected;

  ImageElement({
    this.imagePath,
    this.x = 100,
    this.y = 100,
    this.width = 100,
    this.height = 100,
    this.isSelected = false,
  });
}

class GreetCardController {
  // ------------------------
  // 1. Generate (Base Data)
  // ------------------------
  String selectedFestival = "";
  String customMessage = "";
  String userName = "";

  // Existing festival cards
  final List<String> existingCards = [
    TImages.ambhedkarJayanti,
    TImages.holi,
    TImages.diwali,
    TImages.makarSankranti,
    TImages.christmas,
    TImages.gandhiJayanti,
    TImages.republicDay,
    TImages.independenceDay,
    TImages.janmasthmi,
    TImages.navrati,
    TImages.pongal,
    TImages.newYear,
    TImages.eidAlAdha,
    TImages.eidAlFitr,
    TImages.rakshabandhan,
    TImages.teachersDay,
  ];

  final List<String> backgrounds = [
    TImages.defaultTemplate,
    TImages.defaultTemplate2,
    TImages.defaultTemplate3,
    TImages.defaultTemplate4,
    TImages.defaultTemplate5,
    TImages.defaultTemplate6,
    TImages.defaultTemplate7,
  ];
  int backgroundIndex = 0;
  String? customBackgroundPath;

  // Text elements
  late TextElement festivalElement;
  late TextElement messageElement;
  late TextElement nameElement;

  // Image elements
  List<ImageElement> imageElements = [];

  // Editing state
  EditingMode currentEditingMode = EditingMode.none;

  GreetCardController() {
    initializeElements();
  }

  void initializeElements() {
    festivalElement = TextElement(
      text: "HAPPY",
      x: 50,
      y: 50,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      fontFamily: 'Pacifico',
      color: Colors.deepOrange,
    );

    messageElement = TextElement(
      text: "Wishing you joy and happiness!",
      x: 50,
      y: 200,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: 'Raleway',
      color: Colors.yellowAccent,
    );

    nameElement = TextElement(
      text: "From: Your Name",
      x: 50,
      y: 300,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: 'Roboto',
      color: Colors.red,
    );
  }

  String get currentBackground =>
      customBackgroundPath ?? backgrounds[backgroundIndex];

  void nextBackground() {
    if (customBackgroundPath == null) {
      backgroundIndex = (backgroundIndex + 1) % backgrounds.length;
    }
  }

  void previousBackground() {
    if (customBackgroundPath == null) {
      backgroundIndex =
          (backgroundIndex - 1 + backgrounds.length) % backgrounds.length;
    }
  }

  String get displayFestival {
    if (selectedFestival.toLowerCase().startsWith("happy ")) {
      return selectedFestival.substring(6).trim();
    }
    return selectedFestival.isEmpty ? "Festival" : selectedFestival;
  }

  String get displayMessage {
    if (customMessage.isNotEmpty) return customMessage;
    return getDefaultMessage();
  }

  String getDefaultMessage() {
    final festival = displayFestival.toLowerCase();
    switch (festival) {
      case 'diwali':
        return 'May this Diwali bring light, joy and prosperity to your life!';
      case 'holi':
        return 'May your life be filled with colors of joy and happiness!';
      case 'christmas':
        return 'Wishing you a Merry Christmas filled with love and laughter!';
      case 'new year':
        return 'May the new year bring you happiness and success!';
      case 'eid':
        return 'Eid Mubarak! May this blessed day bring peace and happiness!';
      default:
        return 'Wishing you joy, happiness and prosperity on this special day!';
    }
  }

  void updateCardData(String festival, String message, String name) {
    selectedFestival = festival;
    customMessage = message;
    userName = name;

    festivalElement.text = "HAPPY\n${displayFestival.toUpperCase()}";
    messageElement.text = displayMessage;
    nameElement.text = userName.isEmpty ? "" : "From: $userName";
  }

  // ------------------------
  // 2. Edit Operations
  // ------------------------

  void selectElement(EditingMode mode) {
    // Deselect all
    festivalElement.isSelected = false;
    messageElement.isSelected = false;
    nameElement.isSelected = false;
    for (var img in imageElements) {
      img.isSelected = false;
    }

    currentEditingMode = mode;

    // Select specific element
    switch (mode) {
      case EditingMode.festival:
        festivalElement.isSelected = true;
        break;
      case EditingMode.message:
        messageElement.isSelected = true;
        break;
      case EditingMode.name:
        nameElement.isSelected = true;
        break;
      case EditingMode.none:
        break;
    }
  }

  void updateSelectedTextElement({
    String? text,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
    Color? color,
  }) {
    TextElement? element;

    switch (currentEditingMode) {
      case EditingMode.festival:
        element = festivalElement;
        break;
      case EditingMode.message:
        element = messageElement;
        break;
      case EditingMode.name:
        element = nameElement;
        break;
      default:
        return;
    }

    if (element != null) {
      if (text != null) element.text = text;
      if (fontSize != null) element.fontSize = fontSize;
      if (fontWeight != null) element.fontWeight = fontWeight;
      if (fontFamily != null) element.fontFamily = fontFamily;
      if (color != null) element.color = color;
    }
  }

  void updateElementPosition(EditingMode mode, double dx, double dy) {
    switch (mode) {
      case EditingMode.festival:
        festivalElement.x += dx;
        festivalElement.y += dy;
        break;
      case EditingMode.message:
        messageElement.x += dx;
        messageElement.y += dy;
        break;
      case EditingMode.name:
        nameElement.x += dx;
        nameElement.y += dy;
        break;
      default:
        break;
    }
  }

  void changeBackground(int index) {
    backgroundIndex = index;
    customBackgroundPath = null;
  }

  Future<void> setCustomBackground() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      customBackgroundPath = image.path;
    }
  }

  Future<void> addCustomImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final newImage = ImageElement(
        imagePath: image.path,
        x: 100,
        y: 100,
        width: 100,
        height: 100,
      );
      imageElements.add(newImage);
    }
  }

  // ------------------------
  // 3. Share / Save
  // ------------------------
  Future<File> captureCard(GlobalKey key) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception("RenderObject not found");
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File(
      "${dir.path}/greeting_${displayFestival.replaceAll(' ', '_')}.png",
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> shareCard(GlobalKey key) async {
    final file = await captureCard(key);
    await Share.shareXFiles([
      XFile(file.path),
    ], text: "🎉 ${festivalElement.text} Greetings! ${messageElement.text}");
  }

  Future<void> saveCard(GlobalKey key) async {
    final file = await captureCard(key);
    TDialogs.customToast(message: "Saved successfully");
    print("Card saved: ${file.path}");
  }

  /// Share an existing asset image
  Future<void> shareExistingCard(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/${assetPath.split('/').last}");
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      // Android 11+ ke liye
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    }
  }
}
