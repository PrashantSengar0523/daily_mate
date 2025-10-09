// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io' show Platform;

// class QrCodeScanView extends StatefulWidget {
//   const QrCodeScanView({super.key});

//   @override
//   State<QrCodeScanView> createState() => _QrCodeScanViewState();
// }

// class _QrCodeScanViewState extends State<QrCodeScanView> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   String? lastScanned;
//   bool isProcessing = false;
//   bool flashOn = false;

//   @override
//   void reassemble() {
//     super.reassemble();
//     // Hot reload fix for qr_code_scanner
//     if (Platform.isAndroid) {
//       controller?.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller?.resumeCamera();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("QR Scanner"),
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         actions: [
//           // Flash toggle button
//           IconButton(
//             onPressed: () async {
//               await controller?.toggleFlash();
//               setState(() {
//                 flashOn = !flashOn;
//               });
//             },
//             icon: Icon(
//               flashOn ? Icons.flash_on : Icons.flash_off,
//               color: flashOn ? Colors.yellow : Colors.white,
//             ),
//           ),
//           // Flip camera button
//           IconButton(
//             onPressed: () async {
//               await controller?.flipCamera();
//             },
//             icon: const Icon(Icons.flip_camera_ios),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           QRView(
//             key: qrKey,
//             onQRViewCreated: _onQRViewCreated,
//             overlay: QrScannerOverlayShape(
//               borderColor: Colors.red,
//               borderRadius: 12,
//               borderLength: 30,
//               borderWidth: 6,
//               cutOutSize: 250,
//             ),
//             // Add camera facing and formats
//             cameraFacing: CameraFacing.back,
//             formatsAllowed: const [BarcodeFormat.qrcode],
//           ),

//           // Instructions text
//           Positioned(
//             bottom: 100,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 "Point camera at QR code to scan",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),

//           // Processing overlay
//           if (isProcessing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CircularProgressIndicator(color: Colors.white),
//                     SizedBox(height: 16),
//                     Text(
//                       "Processing QR Code...",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       if (isProcessing) return;

//       final code = scanData.code ?? "";
//       if (code.isEmpty) return;
//       if (code == lastScanned) return;

//       // Pause camera immediately to prevent multiple scans
//       await controller.pauseCamera();

//       setState(() {
//         isProcessing = true;
//         lastScanned = code;
//       });

//       try {
//         await _handleQrCode(code);
//       } catch (e) {
//         print("QR handling error: $e");
//         Get.snackbar(
//           "Error",
//           "Failed to process QR: $e",
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       } finally {
//         // Resume camera after delay
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) {
//           setState(() {
//             isProcessing = false;
//             lastScanned = null;
//           });
//           await controller.resumeCamera();
//         }
//       }
//     });
//   }

//   Future<void> _handleQrCode(String code) async {
//     print("Scanned QR Code: $code");

//     // Check if it's a valid URL
//     if (_isValidUrl(code)) {
//       print("Detected as URL: $code");
//       await _launchUrl(code);
//       return;
//     }

//     // Check if it's an app route
//     if (code.startsWith("app://")) {
//       print("Detected as app route: $code");
//       final route = code.replaceFirst("app://", "");
//       Get.toNamed("/$route");
//       return;
//     }

//     // Plain text - show result screen
//     print("Detected as plain text: $code");
//     Get.to(() => QrResultView(result: code));
//   }

//   bool _isValidUrl(String url) {
//     try {
//       final uri = Uri.tryParse(url);
//       if (uri == null) return false;
      
//       return uri.isAbsolute && 
//              uri.hasScheme && 
//              (uri.scheme == 'http' || uri.scheme == 'https') &&
//              uri.hasAuthority &&
//              uri.host.isNotEmpty;
//     } catch (e) {
//       print("URL validation error: $e");
//       return false;
//     }
//   }

//   Future<void> _launchUrl(String url) async {
//     try {
//       final uri = Uri.parse(url);
//       print("Attempting to launch URL: $uri");
      
//       bool canLaunch = await canLaunchUrl(uri);
//       print("Can launch URL: $canLaunch");
      
//       if (canLaunch) {
//         bool launched = await launchUrl(
//           uri,
//           mode: LaunchMode.externalApplication,
//         );
        
//         if (launched) {
//           Get.snackbar(
//             "Success",
//             "Opening URL in browser...",
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 2),
//           );
//         } else {
//           throw Exception("Failed to launch URL");
//         }
//       } else {
//         throw Exception("Cannot launch this URL");
//       }
//     } catch (e) {
//       print("Launch URL error: $e");
//       Get.snackbar(
//         "Error",
//         "Cannot open URL: $url\nError: ${e.toString()}",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
      
//       // Show as plain text instead
//       Get.to(() => QrResultView(result: url));
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }

// class QrResultView extends StatelessWidget {
//   final String result;
//   const QrResultView({super.key, required this.result});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("QR Result"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               // Add clipboard functionality if needed
//               Get.snackbar(
//                 "Info", 
//                 "Content: ${result.length > 50 ? '${result.substring(0, 50)}...' : result}",
//                 backgroundColor: Colors.blue,
//                 colorText: Colors.white,
//               );
//             },
//             icon: const Icon(Icons.info),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Scanned Content:",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             // Content container
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: SelectableText(
//                 result,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
            
//             const SizedBox(height: 24),

//             // Action buttons
//             if (_isUrl(result)) ...[
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () => _launchInBrowser(result),
//                   icon: const Icon(Icons.open_in_browser),
//                   label: const Text("Open in Browser"),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.all(16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],

//             // Share button (if needed)
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton.icon(
//                 onPressed: () {
//                   // Add share functionality if needed
//                   Get.snackbar("Info", "Share functionality can be added here");
//                 },
//                 icon: const Icon(Icons.share),
//                 label: const Text("Share Content"),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.all(16),
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 12),
            
//             // Scan another button
//             SizedBox(
//               width: double.infinity,
//               child: FilledButton.icon(
//                 onPressed: () => Get.back(),
//                 icon: const Icon(Icons.qr_code_scanner),
//                 label: const Text("Scan Another"),
//                 style: FilledButton.styleFrom(
//                   padding: const EdgeInsets.all(16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   bool _isUrl(String text) {
//     try {
//       final uri = Uri.tryParse(text);
//       return uri != null && uri.isAbsolute && uri.hasScheme;
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<void> _launchInBrowser(String url) async {
//     try {
//       final uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//         Get.snackbar(
//           "Success",
//           "Opening in browser...",
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         Get.snackbar(
//           "Error", 
//           "Cannot open URL",
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Error", 
//         "Failed to open URL: ${e.toString()}",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
// }