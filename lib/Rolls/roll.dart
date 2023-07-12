import 'package:cadets/Helpers/file_helper.dart';
import 'package:cadets/Constants/cadetnet_api.dart';
import '../Helpers/network_helper.dart';
import 'user_mappings.dart';

class Roll {
  final String title;
  bool _synced;
  final Set<String> _attended;
  final Set<String> _expected;

  Roll(this.title, this._synced, this._attended, this._expected);

  void updateRoll(
      {bool? synced, Set<String>? attended, Set<String>? expected}) {
    _synced = synced!;
    _attended.addAll(attended ?? {});
    _expected.addAll(expected ?? {});
  }

  bool get synced => _synced;
  Set<String> get attended => _attended;
  Set<String> get expected => _expected;

  Map<String, dynamic> toJson() => {
        'title': title,
        'synced': _synced,
        'attended': attended.toList(),
        'expected': _expected.toList(),
      };

  static Roll fromJson(MapEntry<String, dynamic> json) => Roll(
        json.key,
        json.value['synced'] as bool,
        Set<String>.from(json.value['attended']),
        Set<String>.from(json.value['expected']),
      );
}

class RollManager {
  static final Set<Roll> _rolls = {};
  static final Session session = Session();

  RollManager() {
    // Load all the file based data:
    loadJsonData("rolls").then((jsonResult) {
      if (jsonResult == Null) {
        return;
      }

      for (var entry in (jsonResult as Map<String, dynamic>).entries) {
        _rolls.add(Roll.fromJson(entry));
      }
    });

    // Load all the online data:
    session.getCookies().then(
          (o1) => session.login().then(
                (o2) => session.getActivities().then(
                  (activities) {
                    activities["DataList"].forEach(
                      (activity) {
                        // Get the attendees for that activity
                        APIPostRequest req = CadetnetApi.postActivityAttendees(
                            activity["Id"] as int);

                        session.getActivityAttendees(req).then(
                          (memberValues) {
                            Set<String> ids = {};

                            // Get the id of the member
                            memberValues["DataList"].forEach((member) {
                              ids.add(
                                  "${member['Member']['MemberDisplay'].split(' - ')[1]}");
                            });

                            // Add member to roll
                            if (rollExists(activity["Name"])) {
                              updateRoll(activity["Name"],
                                  synced: true, expected: ids);
                            } else {
                              _rolls.add(Roll(activity["Name"], true, {}, ids));
                            }

                            saveRolls();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
        );
  }

  static void saveRolls() {
    Map<String, dynamic> json = {};

    for (var roll in _rolls) {
      json.addAll({roll.title: roll.toJson()});
    }

    writeJsonData(json, "rolls");
  }

  static void addAttendee(String rollname, String id) {
    getRoll(rollname)._attended.add(id);
    saveRolls();
  }

  static void deleteAttendee(String rollname, String id) {
    getRoll(rollname)._attended.remove(id);
    saveRolls();
  }

  static bool rollExists(String rollname) {
    return _rolls.map((e) => e.title).contains(rollname);
  }

  static Roll getRoll(String rollname) {
    return _rolls.firstWhere((element) => element.title == rollname);
  }

  static void createRoll(
    String rollname, {
    bool synced = false,
    Set<String>? expected,
  }) {
    _rolls.add(Roll(
      rollname,
      synced,
      {},
      expected ?? {},
    ));
    saveRolls();
  }

  static void updateRoll(
    String rollname, {
    bool? synced,
    Set<String>? attended,
    Set<String>? expected,
  }) {
    if (rollExists(rollname)) {
      getRoll(rollname).updateRoll(
        synced: synced,
        attended: attended,
        expected: expected,
      );
    }
    saveRolls();
  }

  static void deleteRoll(String rollname) {
    _rolls.removeWhere((element) => element.title == rollname);
    saveRolls();
  }

  static Set<String> getAttendees(String rollname) {
    return rollExists(rollname)
        ? getRoll(rollname)
            .attended
            .map((e) => UserMappings.getName(e))
            .where((element) => element != "")
            .toSet()
        : {};
  }

  static Set<String> getExpectedAttendees(String rollname) {
    return rollExists(rollname)
        ? getRoll(rollname)
            .expected
            .map((e) => UserMappings.getName(e))
            .where((element) => element != "")
            .toSet()
        : {};
  }

  static Set<String> getCadetsAway(String rollname) {
    return getRoll(rollname)
        .expected
        .difference(getRoll(rollname).attended)
        .map((e) => UserMappings.getName(e))
        .where((element) => element != "")
        .toSet();
  }

  static bool isRollSynced(String rollname) {
    return rollExists(rollname) ? getRoll(rollname).synced : false;
  }

  static Set<Roll> get rolls => _rolls;
}
