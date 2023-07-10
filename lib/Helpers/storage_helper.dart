import 'dart:convert';
import 'dart:io';
import 'package:cadets/Constants/cadetnet_api.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'network_helper.dart';

class Roll {
  final String title;
  bool synced;
  Set<String> attended;
  Set<String> expected;

  Roll(this.title, this.synced, this.attended, this.expected);

  Map<String, dynamic> toJson() => {
        'title': title,
        'synced': synced,
        'attended': attended.toList(),
        'expected': expected.toList(),
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
            key,
            value['synced'] as bool,
            Set<String>.from(value['attended']),
            Set<String>.from(value['expected']));
        _rolls[key] = roll;
        _rollNames.add(key);
      });
    }
  }

  Future<void> loadOnlineData() async {
    session.getCookies().then((value) =>
        session.login().then((value) => session.getActivities().then((value) {
              value["DataList"].forEach((entry) {
                // print(entry);
                APIPostRequest req =
                    CadetnetApi.postActivityAttendees(entry["Id"] as int);

                session.getActivityAttendees(req).then((memberValues) {
                  Set<String> ids = {};

                  memberValues["DataList"].forEach((member) {
                    ids.add(
                        "${member['Member']['MemberDisplay'].split(' - ')[1]}");
                  });

                  // print('IDS == $ids');

                  createRoll(entry["Name"], synced: true, expected: ids);
                  // print(_rolls[entry["Name"]]?.toJson());
                });
              });
            })));
  }

  void createRoll(String rollname,
      {bool synced = false, Set<String>? expected}) async {
    if (_rolls.containsKey(rollname)) {
      _rolls[rollname]?.synced = synced;
      _rolls[rollname]?.expected.clear();
      _rolls[rollname]?.expected.addAll(expected ?? {});
      _saveToJson();
      return;
    }

    Roll roll = Roll(rollname, synced, {}, expected ?? {});
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
    Map<String, dynamic> rollsJsonified = {};

    for (MapEntry<String, Roll> element in _rolls.entries) {
      rollsJsonified.addAll({element.key: element.value.toJson()});
    }

    // print(rollsJsonified);

    final jsonData = json.encode(rollsJsonified);

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

  Set<String> getExpectedNames(String rollname) {
    return _rolls[rollname]!
        .expected
        .map((e) => UserMappings.getName(e))
        .where((e) => e != "")
        .toSet();
  }

  Set<String> getCadetsAway(String rollname) {
    return _rolls[rollname]!
        .expected
        .difference(_rolls[rollname]!.attended)
        .map((e) => UserMappings.getName(e))
        .where((e) => e != "")
        .toSet();
  }

  Map<String, dynamic> get rolls => _rolls;
  Set<String> get rollnames => _rollNames;
}

class UserMappings {
  static Map<String, String> _data = {};
  static final Map<String, String> _reversed = {};
  static final List<String> _options = [];
  final Session session = Session();

  Future<void> loadData() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/mapper.json';

    // Check if the file exists
    final file = File(filePath);
    final fileExists = await file.exists();

    if (fileExists) {
      String data = await file.readAsString();
      final jsonResult = jsonDecode(data);
      _data = Map<String, String>.from(jsonResult);
      for (var element in _data.entries) {
        _reversed.putIfAbsent(element.value.toLowerCase(), () => element.key);
        _options.add(element.value.toLowerCase());
      }
    } else {
      await loadOnlineData();
    }
  }

  Future<void> loadOnlineData() async {
    session.getCookies().then(
          (value) => session.login().then(
                (value) => session.getUserMapping().then(
                  (value) {
                    value["DataList"].forEach((member) {
                      _data.addAll({
                        member["MemberDisplay"].split(" - ")[1]:
                            member["MemberDisplay"]
                      });
                    });

                    for (var element in _data.entries) {
                      _reversed.putIfAbsent(
                          element.value.toLowerCase(), () => element.key);
                      _options.add(element.value.toLowerCase());
                    }
                  },
                ),
              ),
        );

    final jsonData = json.encode(_data);

    // Get the documents directory path
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/mapper.json';

    // Write the JSON data to the file
    final file = File(filePath);
    await file.writeAsString(jsonData);
  }

  List<String> get options => _options;

  static String getId(String full) {
    return _reversed[full] ?? "";
  }

  static String getName(String id) {
    return _data[id] ?? "";
  }
}
