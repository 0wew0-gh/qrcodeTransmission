import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrcodeTransmission/data.dart';
import 'package:qrcodeTransmission/process_strings.dart';
import 'package:qrcodeTransmission/scanner_error_widget.dart';

class BarcodeScannerWithOverlay extends StatefulWidget {
  const BarcodeScannerWithOverlay({super.key});

  @override
  State<BarcodeScannerWithOverlay> createState() =>
      _BarcodeScannerWithOverlayState();
}

class _BarcodeScannerWithOverlayState extends State<BarcodeScannerWithOverlay> {
  String overlayText = "Please scan QR Code";
  List<String> _list = [];
  bool camStarted = true;

  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    // detectionSpeed: DetectionSpeed.unrestricted,
    // autoStart: true,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startCamera() {
    if (camStarted) {
      return;
    }

    controller.start().then((_) {
      if (mounted) {
        setState(() {
          camStarted = true;
        });
      }
    }).catchError((Object error, StackTrace stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong! $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void onBarcodeDetect(BarcodeCapture barcodeCapture) {
    final barcode = barcodeCapture.barcodes.last;
    String tempStr =
        barcodeCapture.barcodes.last.displayValue ?? barcode.rawValue ?? '';
    print(">>>>>>>>>>>>>>>>>>> $tempStr");
    _list = addList(_list, tempStr);
    print(">>> 1111111111 $_list");
    List<String> msgs = joinStrings(_list);
    print(">>> 2222222222 $msgs");
    if (msgs[0] == "") {
      print(">>> Done: ${msgs[1]}");
      setState(() {
        overlayText = msgs[1];
      });
    } else {
      setState(() {
        overlayText = tempStr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Scanner with Overlay Example app'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: camStarted
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: MobileScanner(
                            fit: BoxFit.cover,
                            onDetect: onBarcodeDetect,
                            // overlay: CustomPaint(
                            //   painter: ScannerOverlay(Rect.fromCenter(
                            //     center: Offset.zero,
                            //     width: scanRectSize,
                            //     height: scanRectSize,
                            //   )),
                            // ),
                            controller: controller,
                            scanWindow: scanWindow,
                            errorBuilder: (context, error, child) {
                              return ScannerErrorWidget(error: error);
                            },
                          ),
                        ),
                        CustomPaint(
                          painter: ScannerOverlay(scanWindow),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Opacity(
                              opacity: 0.7,
                              child: Text(
                                overlayText,
                                style: const TextStyle(
                                  backgroundColor: Colors.black26,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  // overflow: TextOverflow.ellipsis,
                                ),

                                // maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ValueListenableBuilder<TorchState>(
                                  valueListenable: controller.torchState,
                                  builder: (context, value, child) {
                                    final Color iconColor;

                                    switch (value) {
                                      case TorchState.off:
                                        iconColor = Colors.black;
                                        break;
                                      case TorchState.on:
                                        iconColor = Colors.yellow;
                                        break;
                                    }

                                    return IconButton(
                                      onPressed: () => controller.toggleTorch(),
                                      icon: Icon(
                                        Icons.flashlight_on,
                                        color: iconColor,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  onPressed: () => controller.switchCamera(),
                                  icon: const Icon(
                                    Icons.cameraswitch_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      overlayText = "Please scan QR Code";
                                      _list = [];
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 36.0,
                            left: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text("Tap on Camera to activate QR Scanner"),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: camStarted
          ? null
          : FloatingActionButton(
              onPressed: startCamera,
              child: const Icon(Icons.camera_alt),
            ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;
  final double borderRadius = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Create a Paint object for the white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0; // Adjust the border width as needed

    // Calculate the border rectangle with rounded corners
// Adjust the radius as needed
    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // Draw the white border
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
