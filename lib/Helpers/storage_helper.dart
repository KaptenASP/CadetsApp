import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'network_helper.dart';

class Rolls {
  final Map<String, Map<String, List<String>>> _rolls = {};
  final List<String> _rollNames = [];
  final Session session = Session();

  Future<void> loadData() async {
    // Get the documents directory path
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/rolls.json';

    // Check if the file exists
    final file = File(filePath);
    final fileExists = await file.exists();

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

    loadOnlineData();
  }

  Future<void> loadOnlineData() async {
    session.getCookies().then((value) =>
        session.login().then((value) => session.getActivities().then((value) {
              value["DataList"].forEach((entry) {
                print(entry);
                createRoll(entry["Name"]);
              });
            })));
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

  Set<String> getAttendedNames(String rollname) {
    return Set<String>.from(_rolls[rollname]?['attended']
        ?.map((e) => UserMappings.getName(e)) as Iterable);
  }

  Map<String, dynamic> get rolls => _rolls;
  List<String> get rollnames => _rollNames;
}

class UserMappings {
  static Map<String, String> _data = {};
  static final Map<String, String> _reversed = {};
  static final List<String> _options = [];

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

  static String getId(String full) {
    return _reversed[full] ?? "";
  }

  static String getName(String id) {
    return _data[id] ?? "";
  }
}
