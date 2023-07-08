import 'package:flutter/material.dart';
import 'rolls.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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
  Rolls rolls = Rolls();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadets V2.0"),
      ),
      body: FutureBuilder<void>(
        future: rolls.loadData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else {
            return ListView(
              scrollDirection: Axis.vertical,
              children: rolls.rollnames
                  .map((e) => ElevatedButton(
                        child: Text(e),
                        onPressed: () {},
                      ))
                  .toList(),
            );
          }
        },
      ),
    );
  }
}

class Rolls {
  Map<String, dynamic> _rolls = {};
  final List<String> _rollNames = [];

  Future<void> loadData() async {
    String data = await rootBundle.loadString('assets/rolls.json');
    final jsonResult = jsonDecode(data);
    _rolls = Map<String, dynamic>.from(jsonResult);
    _rolls.forEach((key, value) {
      _rollNames.add(key);
    });
  }

  Map<String, dynamic> get rolls => _rolls;
  List<String> get rollnames => _rollNames;
}
