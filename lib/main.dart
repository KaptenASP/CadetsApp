import 'package:flutter/material.dart';
import 'attendance_marker.dart';
import 'Rolls/roll.dart';
import 'Rolls/user_mappings.dart';

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
        // Convert from purple hue to blue hue
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          backgroundColor: const Color(0xff0d1117),
          cardColor: const Color(0xff010409),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RollManager rollManager = RollManager();
  final UserMappings userMappings = UserMappings();
  TextEditingController rollNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void createRoll(String rollname) {
    RollManager.createRoll(rollname);
    setState(() {});
  }

  void deleteRoll(String rollname) {
    RollManager.deleteRoll(rollname);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadets V2.0"),
        actions: <Widget>[
          TextButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Enter Roll Name'),
                content: TextFormField(
                  controller: rollNameController,
                  decoration: const InputDecoration(
                    hintText: 'Roll Name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      createRoll(rollNameController.text);
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: const Text('Create Roll'),
          ),
          TextButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Enter Roll Name To Confirm Delete'),
                content: TextFormField(
                  controller: rollNameController,
                  decoration: const InputDecoration(
                    hintText: 'Roll Name',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      deleteRoll(rollNameController.text);
                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: const Text('Delete roll'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {});
          });
        },
        child: ListView(
          scrollDirection: Axis.vertical,
          children: (RollManager.rolls)
              .map((e) => Card(
                    margin: const EdgeInsets.all(0),
                    elevation: 0,
                    color: const Color(0xff0d1117),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xff30363d)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      splashColor: const Color(0xff161b22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RollHome(
                                    rollname: e.title,
                                  )),
                        );
                        debugPrint('card name: ${e.title} -- ${e.synced}');
                        debugPrint('Card tapped.');
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: Align(
                            // Add some left padding to text
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  e.synced
                                      ? const Icon(Icons.wifi_outlined,
                                          color: Color(0xff7d8590))
                                      : const Icon(Icons.wifi_off_outlined,
                                          color: Color(0xff7d8590)),
                                  Text(
                                    '    ${e.title}',
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
