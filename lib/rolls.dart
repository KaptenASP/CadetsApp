import 'Helpers/storage_helper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class RollHome extends StatefulWidget {
  final String rollname;
  final Rolls rolls;
  const RollHome({Key? key, required this.rollname, required this.rolls})
      : super(key: key);

  @override
  State<RollHome> createState() => _RollHomeState();
}

class _RollHomeState extends State<RollHome> {
  final UserMappings _userMappings = UserMappings();
  late final RollMarking _rollMarking;
  final GlobalKey<_RollMarkingState> _rollMarkingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _userMappings.loadData();
    _rollMarking = RollMarking(
        userMappings: _userMappings,
        rolls: widget.rolls,
        rollname: widget.rollname,
        onAddAttendee: (String id) {
          setState(() {});
        },
        key: _rollMarkingKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadet Attendance Scanner'),
      ),
      body: ListView(
        children: [
          Text(widget.rollname),
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.rolls.getAttended(widget.rollname).length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    widget.rolls.getAttended(widget.rollname).elementAt(index)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RollMarking extends StatefulWidget {
  final UserMappings userMappings;
  final void Function(String) onAddAttendee;
  final Rolls rolls;
  final String rollname;
  @override
  final GlobalKey<_RollMarkingState> key;

  const RollMarking(
      {required this.userMappings,
      required this.onAddAttendee,
      required this.rolls,
      required this.rollname,
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
  Set<String> _attended = {};
  String _lastSuccessfulMark = "";

  @override
  void initState() {
    super.initState();
    _attended = widget.rolls.getAttended(widget.rollname);
    _lastSuccessfulMark =
        _attended.isNotEmpty ? widget.userMappings.getName(_attended.last) : '';
  }

  void addAttendee(String id) {
    setState(() {
      if (_attended.add(id)) {
        widget.rolls.saveId(widget.rollname, id);
      }
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
