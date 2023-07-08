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
  late final RollMarking _rollMarking;
  final GlobalKey<_RollMarkingState> _rollMarkingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _userMappings.loadData();
    _rollMarking = RollMarking(
        userMappings: _userMappings,
        onAddAttendee: (String id) {
          setState(() {});
        },
        key: _rollMarkingKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadet Attendance Scanner"),
      ),
      body: ListView(
        children: [
          _rollMarking,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchCadet(
              userMappings: _userMappings,
              rollMarking: _rollMarking,
            ),
          ),
          Scanner(
            userMappings: _userMappings,
            rollMarking: _rollMarking,
          ),
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

  String getName(String id) {
    return _data[id] ?? "";
  }
}

class RollMarking extends StatefulWidget {
  final UserMappings userMappings;
  final void Function(String) onAddAttendee;
  @override
  final GlobalKey<_RollMarkingState> key;

  const RollMarking(
      {required this.userMappings,
      required this.onAddAttendee,
      required this.key})
      : super(key: key);

  @override
  State<RollMarking> createState() => _RollMarkingState();

  void addAttendee(String id) {
    _RollMarkingState state = key.currentState!;
    state.addAttendee(id);
  }
}

class _RollMarkingState extends State<RollMarking> {
  final Set<String> _attended = {};
  String _lastSuccessfulMark = "";

  void addAttendee(String id) {
    setState(() {
      _attended.add(id);
      _lastSuccessfulMark = widget.userMappings.getName(id);
    });
    widget.onAddAttendee(id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: Text('last successful mark: $_lastSuccessfulMark'),
    );
  }
}

class SearchCadet extends StatefulWidget {
  final UserMappings userMappings;
  final RollMarking rollMarking;

  const SearchCadet(
      {Key? key, required this.userMappings, required this.rollMarking})
      : super(key: key);

  @override
  State<SearchCadet> createState() => _SearchCadetState();
}

class _SearchCadetState extends State<SearchCadet> {
  final TextEditingController _textEditingController = TextEditingController();

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
        widget.rollMarking.addAttendee(widget.userMappings.getId(selection));
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        _textEditingController.value = textEditingController.value;
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                onSubmitted: (String value) {
                  widget.rollMarking
                      .addAttendee(widget.userMappings.getId(value));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                textEditingController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}

class Scanner extends StatefulWidget {
  final UserMappings userMappings;
  final RollMarking rollMarking;

  const Scanner(
      {Key? key, required this.userMappings, required this.rollMarking})
      : super(key: key);

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
            child: Text('Last successfully saved: $_lastScannedCode'),
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
                    if (_barcodes.add('${barcode.rawValue}')) {
                      setState(() {
                        _lastScannedCode =
                            widget.userMappings.getName('${barcode.rawValue}');
                        widget.rollMarking.addAttendee('${barcode.rawValue}');
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
