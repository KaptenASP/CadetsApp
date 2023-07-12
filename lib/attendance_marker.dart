import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'Rolls/roll.dart';
import 'Rolls/user_mappings.dart';

// The homepage of the attendance scanner
class RollHome extends StatefulWidget {
  final String rollname;
  const RollHome({Key? key, required this.rollname}) : super(key: key);

  @override
  State<RollHome> createState() => _RollHomeState();
}

class _RollHomeState extends State<RollHome> {
  // Widget to show last scanned cadet + save marked attendance
  static late RollMarking _rollMarking;
  final GlobalKey<_RollMarkingState> _rollMarkingKey = GlobalKey();

  // Index to keep track of the pages
  int index = 0;

  @override
  void initState() {
    super.initState();
    _rollMarking = RollMarking(
      rollname: widget.rollname,
      onAddAttendee: (String id) {
        setState(() {});
      },
      rollMarkingKey: _rollMarkingKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rollname),
      ),
      body: Stack(children: <Widget>[
        Offstage(
          // Homepage - the scanner
          offstage: index != 0,
          child: TickerMode(
            enabled: index == 0,
            child: ListView(
              children: [
                _rollMarking,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  // Search bar to search up cadets
                  child: SearchCadet(
                    rollMarking: _rollMarking,
                  ),
                ),
                Scanner(
                  // Scanner to scan cadet ids
                  rollMarking: _rollMarking,
                ),
                // Create a list at bottom of screen displaying all cadets who have been scanned
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: RollManager.getAttendees(widget.rollname).length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(0),
                      elevation: 0,
                      color: const Color(0xff0d1117),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xff30363d)),
                      ),
                      child: ListTile(
                        title: Text(
                          RollManager.getAttendees(widget.rollname)
                              .elementAt(index),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Offstage(
          // Page to show all cadets who are away
          offstage: index != 1,
          child: TickerMode(
            enabled: index == 1,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: RollManager.getCadetsAway(widget.rollname).length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(0),
                  elevation: 0,
                  color: const Color(0xff0d1117),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xff30363d)),
                  ),
                  child: ListTile(
                    title: Text(RollManager.getCadetsAway(widget.rollname)
                        .elementAt(index)),
                  ),
                );
              },
            ),
          ),
        ),
        Offstage(
          // Page to show all cadets who are expected to be at the activity
          offstage: index != 2,
          child: TickerMode(
            enabled: index == 2,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount:
                  RollManager.getExpectedAttendees(widget.rollname).length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(0),
                  elevation: 0,
                  color: const Color(0xff0d1117),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xff30363d)),
                  ),
                  child: ListTile(
                    title: Text(
                        RollManager.getExpectedAttendees(widget.rollname)
                            .elementAt(index)),
                  ),
                );
              },
            ),
          ),
        )
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (int index) {
          setState(() {
            this.index = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.sick), label: 'away'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'info'),
        ],
      ),
    );
  }
}

class RollMarking extends StatefulWidget {
  final void Function(String) onAddAttendee;
  final String rollname;
  final GlobalKey<_RollMarkingState> rollMarkingKey;

  const RollMarking(
      {required this.onAddAttendee,
      required this.rollname,
      required this.rollMarkingKey})
      : super(key: rollMarkingKey);

  @override
  State<RollMarking> createState() => _RollMarkingState();

  void addAttendee(String id) {
    _RollMarkingState state = rollMarkingKey.currentState!;
    state.addAttendee(id);
  }
}

class _RollMarkingState extends State<RollMarking> {
  String _lastSuccessfulMark = "";

  @override
  void initState() {
    super.initState();
    _lastSuccessfulMark = RollManager.getAttendees(widget.rollname).isNotEmpty
        ? RollManager.getAttendees(widget.rollname).last.toString()
        : "";
  }

  void addAttendee(String id) {
    setState(() {
      debugPrint('Inside addAttendee: $id');
      RollManager.addAttendee(
        widget.rollname,
        id,
      );
      _lastSuccessfulMark = UserMappings.getName(id);
    });
    widget.onAddAttendee(id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

class SearchCadet extends StatefulWidget {
  final RollMarking rollMarking;

  const SearchCadet({Key? key, required this.rollMarking}) : super(key: key);

  @override
  State<SearchCadet> createState() => _SearchCadetState();
}

class _SearchCadetState extends State<SearchCadet> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF30363d),
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<String>.empty();
          }
          return UserMappings.getAllNames().where(
            (String option) {
              return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
            },
          );
        },
        onSelected: (String selection) {},
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  onSubmitted: (String value) {
                    widget.rollMarking.addAttendee(UserMappings.getId(value));
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textEditingController.clear();
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  debugPrint(textEditingController.text);
                  debugPrint(UserMappings.getId(textEditingController.text));
                  widget.rollMarking.addAttendee(
                      UserMappings.getId(textEditingController.text));
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class Scanner extends StatefulWidget {
  final RollMarking rollMarking;

  const Scanner({Key? key, required this.rollMarking}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _isCameraStarted = true;
  bool _flashOn = false;
  bool _rearCamera = true;

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
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _toggleCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2ea043),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isCameraStarted
                    ? const Icon(
                        Icons.pause,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
              ),
              ElevatedButton(
                onPressed: _toggleFlash,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2ea043),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                child: _flashOn
                    ? const Icon(Icons.flash_on, color: Colors.white)
                    : const Icon(Icons.flash_off, color: Colors.white),
              ),
              ElevatedButton(
                  onPressed: _toggleInUseCamera,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2ea043),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Icon(
                    Icons.switch_camera,
                    color: Colors.white,
                  )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF30363d),
                    width: 2.0,
                  ),
                ),
                child: MobileScanner(
                  fit: BoxFit.fitWidth,
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      setState(() {
                        widget.rollMarking.addAttendee('${barcode.rawValue}');
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
