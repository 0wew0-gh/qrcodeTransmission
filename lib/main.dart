import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcodeTransmission/barcode_scanner_zoom.dart';
import 'package:qrcodeTransmission/data.dart';
import 'package:qrcodeTransmission/mobile_scanner_overlay.dart';
import 'package:qrcodeTransmission/process_strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController qrStrController = TextEditingController(
    text: "Debug service listening on ws://127.0.0.1:12503/KKG8e6yqptU=/ws",
  );
  TextEditingController lenController = TextEditingController(text: "25");
  TextEditingController durationController = TextEditingController(text: "200");
  // String msg =
  // "Debug service listening on ws://127.0.0.1:12503/KKG8e6yqptU=/ws";
  List<String> qrList = [];
  String qrStr = "";

  Timer? qrTimer;

  @override
  void initState() {
    super.initState();
  }

  void setTimer() {
    Timer.periodic(
        Duration(
          milliseconds: int.parse(durationController.text),
        ), (timer) {
      qrTimer = timer;
      if (qrList.isNotEmpty) {
        if (qrStr.isEmpty) {
          if (mounted) {
            setState(() {
              qrStr = qrList[0];
            });
            return;
          }
        }
        bool isNext = false;
        for (var v in qrList) {
          if (isNext) {
            if (mounted) {
              setState(() {
                qrStr = v;
              });
            }
            isNext = false;
            break;
          }
          if (v == qrStr) {
            isNext = true;
          }
        }
        if (isNext) {
          if (mounted) {
            setState(() {
              qrStr = qrList[0];
            });
          }
        }
      }
      print(">>> qrStr: $qrStr");
    });
  }

  @override
  Widget build(BuildContext context) {
    double scanWidth = MediaQuery.of(context).size.width * 0.8;
    double scanHeight = MediaQuery.of(context).size.height * 0.8;
    scanRectSize = scanWidth > scanHeight ? scanHeight : scanWidth;
    scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: scanRectSize,
      height: scanRectSize,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: qrStrController,
              decoration: const InputDecoration(labelText: "QR字符串"),
            ),
            TextField(
              controller: lenController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "分隔长度"),
            ),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "间隔"),
            ),
            ElevatedButton(
              onPressed: () {
                // List<String> list = [
                //   "",
                //   "",
                //   "<qrI:2>n ws://127.0.0.1:12503/KK",
                //   "<qrE:3>G8e6yqptU=/ws",
                //   "<qrS:63|25>Debug service l"
                // ];
                // print(">>> list: $list");
                // List<String> newList = sortList(list);
                // print(">>> newList: $newList");
                qrList = splitStrings(
                  qrStrController.text,
                  int.parse(lenController.text),
                );
                print(">>> ${qrStrController.text}");
                // print(">>> $list");
                // List<String> list = [
                //   "<qrI:2>n ws://127.0.0.1:12503/KK",
                //   "<qrE:3>G8e6yqptU=/ws",
                //   "<qrS:63|25>Debug service l"
                // ];
                List<String> newList = sortList(qrList);
                print(">>> newList: $newList");
                List<String> newMsg = joinStrings(newList);
                if (newMsg[0] != "") {
                  print(">>> Error <<<: ${newMsg[0]}");
                } else {
                  print(">>> newMsg <<<: ${newMsg[1]}");
                }
                qrStr = "";
                if (qrTimer != null) {
                  qrTimer!.cancel();
                  qrTimer = null;
                }
                setTimer();
              },
              child: const Text('处理字符串'),
            ),
            qrStr.isEmpty
                ? const SizedBox(height: 200)
                : QrImageView(
                    data: qrStr,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
            ElevatedButton(
              onPressed: () {
                if (qrTimer != null) {
                  qrTimer!.cancel();
                  qrTimer = null;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithZoom(),
                  ),
                );
              },
              child: const Text('MobileScanner with zoom slider'),
            ),
            ElevatedButton(
              onPressed: () {
                if (qrTimer != null) {
                  qrTimer!.cancel();
                  qrTimer = null;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithOverlay(),
                  ),
                );
              },
              child: const Text('scan'),
            ),
          ],
        ),
      ),
    );
  }
}
