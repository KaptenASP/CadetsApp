import 'package:flutter/material.dart';
import 'rolls.dart';
import 'Helpers/storage_helper.dart';

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
  final Rolls _rolls = Rolls();
  TextEditingController rollNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rolls.loadData().then((value) {
      setState(() {});
    });

    _rolls.loadOnlineData().then((value) {
      setState(() {});
    });
  }

  void createRoll(String rollname) {
    _rolls.createRoll(rollname);
    setState(() {});
  }

  void deleteRoll(String rollname) {
    _rolls.deleteRoll(rollname);
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
      body: ListView(
        scrollDirection: Axis.vertical,
        children: (_rolls.rolls.entries as Iterable<MapEntry<String, Roll>>)
            .map((e) => Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RollHome(
                                  rollname: e.value.title,
                                  rolls: _rolls,
                                )),
                      );
                      debugPrint(
                          'card name: ${e.value.title} -- ${e.value.synced}');
                      debugPrint('Card tapped.');
                    },
                    child: SizedBox(
                      width: 300,
                      height: 100,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "${e.value.synced ? '🟢' : '🟠'} ${e.value.title}")),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
