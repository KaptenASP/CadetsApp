import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Rolls {
  final Map<String, Map<String, List<String>>> _rolls = {};
  final List<String> _rollNames = [];

  Future<void> loadData() async {
    // Get the documents directory path
    print("Starting");
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/rolls.json';

    print("Got filepath");

    // Check if the file exists
    final file = File(filePath);
    final fileExists = await file.exists();

    print(fileExists);

    if (fileExists) {
      String data = await file.readAsString();
      final jsonResult = jsonDecode(data);

      // Add casted entries into _rolls:
      (jsonResult as Map<String, dynamic>).forEach((key, value) {
        // print(jsonResult..);
        Map<String, List<String>> nestedMap = {};

        (value as Map<String, dynamic>).forEach((nestedKey, nestedValue) {
          nestedMap[nestedKey] = List<String>.from(nestedValue);
        });

        _rolls[key] = nestedMap;
        _rollNames.add(key);
      });
    }
  }

  void createRoll(String rollname) async {
    if (_rolls.containsKey(rollname)) {
      return;
    }

    _rolls[rollname] = {'attended': []};
    _rollNames.add(rollname);
    _saveToJson();
  }

  void deleteRoll(String rollname) async {
    _rolls.remove(rollname);
    _rollNames.remove(rollname);
    _saveToJson();
  }

  void saveId(String rollname, String id) async {
    _rolls[rollname]?['attended']?.add(id);
    _saveToJson();
  }

  Future<void> _saveToJson() async {
    final jsonData = jsonEncode(_rolls);

    // Get the documents directory path
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/rolls.json';

    // Write the JSON data to the file
    final file = File(filePath);
    await file.writeAsString(jsonData);
  }

  Set<String> getAttended(String rollname) {
    return Set<String>.from(_rolls[rollname]?['attended'] as Iterable);
  }

  Map<String, dynamic> get rolls => _rolls;
  List<String> get rollnames => _rollNames;
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
