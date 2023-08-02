import 'package:cadets/Rolls/user_mappings.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cadets/Rolls/roll.dart';

class Scanner extends StatefulWidget {
  final String rollname;

  const Scanner({Key? key, required this.rollname}) : super(key: key);
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _isCameraStarted = true;
  bool _flashOn = false;
  String _lastSuccessfulMark = "";

  final MobileScannerController cameraController = MobileScannerController();

  void _toggleCamera() {
    setState(() {
      if (_isCameraStarted) {
        cameraController.stop();
      } else {
        cameraController.start();
      }
      _isCameraStarted = !_isCameraStarted;
    });
  }

  void _toggleFlash() {
    setState(() {
      cameraController.toggleTorch();
      _flashOn = !_flashOn;
    });
  }

  void _toggleInUseCamera() {
    setState(() {
      cameraController.switchCamera();
    });
  }

  @override
  void initState() {
    super.initState();
    cameraController.stop();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        // Add a button on app bar to pause camera
        actions: [
          IconButton(
            onPressed: () {
              _toggleCamera();
            },
            icon: _isCameraStarted
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: _toggleFlash,
            icon: _flashOn
                ? const Icon(Icons.flash_on)
                : const Icon(Icons.flash_off),
          ),
          IconButton(
            onPressed: _toggleInUseCamera,
            icon: const Icon(Icons.switch_camera),
          )
        ],
      ),
      body: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(
                color: Color(0xFF1d572d),
                width: 2.0,
              ),
            ),
            color: const Color(0xff12261e),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  children: [
                    const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    const Text(
                      '  Last successful mark:    ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(_lastSuccessfulMark.split(" - ")[0]),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF30363d),
                  width: 2.0,
                ),
              ),
              child: MobileScanner(
                fit: BoxFit.fitHeight,
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    setState(() {
                      _lastSuccessfulMark =
                          UserMappings.getName('${barcode.rawValue}');
                      RollManager.addAttendee(
                          widget.rollname, '${barcode.rawValue}');
                      setState(() {});
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
