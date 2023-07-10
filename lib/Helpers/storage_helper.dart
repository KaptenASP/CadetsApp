import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'network_helper.dart';

class Roll {
  final String title;
  bool synced;
  Set<String> attended;

  Roll(this.title, this.synced, this.attended);

  Map<String, dynamic> toJson() => {
        'title': title,
        'synced': synced,
        'attended': attended.toList(),
      };
}

class Rolls {
  final Map<String, Roll> _rolls = {};
  final Set<String> _rollNames = {};
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
        value = (value as Map<String, dynamic>);

        Roll roll = Roll(
            key, value['synced'] as bool, Set<String>.from(value['attended']));
        _rolls[key] = roll;
        _rollNames.add(key);
      });
    }
  }

  Future<void> loadOnlineData() async {
    session.getCookies().then((value) =>
        session.login().then((value) => session.getActivities().then((value) {
              value["DataList"].forEach((entry) {
                createRoll(entry["Name"], synced: true);
              });
            })));
  }

  void createRoll(String rollname, {bool synced = false}) async {
    if (_rolls.containsKey(rollname)) {
      _rolls[rollname]?.synced = synced;
      return;
    }

    Roll roll = Roll(rollname, synced, {});
    _rolls[rollname] = roll;
    _rollNames.add(rollname);
    _saveToJson();
  }

  void deleteRoll(String rollname) async {
    if (_rolls.containsKey(rollname) && _rolls[rollname]!.synced) {
      return;
    }

    _rolls.remove(rollname);
    _rollNames.remove(rollname);
    _saveToJson();
  }

  void saveId(String rollname, String id) async {
    _rolls[rollname]?.attended.add(id);
    _saveToJson();
  }

  Future<void> _saveToJson() async {
    Map<String, dynamic> _rollsJsonified = {};

    for (MapEntry<String, Roll> element in _rolls.entries) {
      _rollsJsonified.addAll({element.key: element.value.toJson()});
    }

    print(_rollsJsonified);

    final jsonData = json.encode(_rollsJsonified);

    // Get the documents directory path
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/rolls.json';

    // Write the JSON data to the file
    final file = File(filePath);
    await file.writeAsString(jsonData);
  }

  Set<String> getAttended(String rollname) {
    return _rolls[rollname]!.attended;
  }

  Set<String> getAttendedNames(String rollname) {
    return _rolls[rollname]!
        .attended
        .map((e) => UserMappings.getName(e))
        .toSet();
  }

  Map<String, dynamic> get rolls => _rolls;
  Set<String> get rollnames => _rollNames;
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
