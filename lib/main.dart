import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final UserMappings _userMappings = UserMappings();

  @override
  void initState() {
    super.initState();
    _userMappings.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadet Attendance Scanner"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SearchCadet(
              userMappings: _userMappings,
            ), //SearchBar(),
          ),
          Scanner(),
        ],
      ),
    );
  }
}

class UserMappings {
  Map<String, String> _data = {};
  final Map<String, String> _reversed = {};
  final List<String> _options = [];

  Future<void> loadData() async {
    String data = await rootBundle.loadString('assets/mapper.json');
    final jsonResult = jsonDecode(data);
    _data = Map<String, String>.from(jsonResult);
    for (var element in _data.entries) {
      _reversed.putIfAbsent(element.value.toLowerCase(), () => element.key);
      _options.add(element.value.toLowerCase());
    }
  }

  List<String> get options => _options;

  String getId(String full) {
    return _reversed[full] ?? "";
  }
}

class SearchCadet extends StatefulWidget {
  final UserMappings userMappings;

  SearchCadet({Key? key, required this.userMappings}) : super(key: key);

  @override
  State<SearchCadet> createState() => _SearchCadetState();
}

class _SearchCadetState extends State<SearchCadet> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return widget.userMappings.options.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        debugPrint('You just selected $selection');
        debugPrint(widget.userMappings.getId(selection));
      },
    );
  }
}

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _isCameraStarted = true;
  bool _flashOn = false;
  bool _rearCamera = true;
  final Set<String> _barcodes = {};
  String? _lastScannedCode;

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
      _rearCamera = !_rearCamera;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            child: Text('Last successfully scanned code: $_lastScannedCode'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _toggleCamera,
                child: Text(_isCameraStarted ? 'Pause' : 'Play'),
              ),
              ElevatedButton(
                  onPressed: _toggleFlash,
                  child: Text(
                    _flashOn ? 'Flash On' : 'Flash Off',
                  )),
              ElevatedButton(
                  onPressed: _toggleInUseCamera,
                  child: Text(
                    _rearCamera ? 'Front Camera' : 'Rear Camera',
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.topCenter,
              child: MobileScanner(
                fit: BoxFit.contain,
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    _lastScannedCode = '${barcode.rawValue}';
                    if (_barcodes.add('${barcode.rawValue}')) {
                      setState(() {
                        _lastScannedCode = barcode.rawValue;
                      });
                    }
                  }
                },
              ),
            ),
          ),
          ..._barcodes.map((barcode) => ListTile(title: Text(barcode)))
        ],
      ),
    );
  }
}
