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
  static final Set<Roll> rolls = {};
  static final Session session = Session();

  RollManager() {
    // Load all the file based data:
    loadJsonData("rolls").then((jsonResult) {
      if (jsonResult == Null) {
        return;
      }

      for (var entry in (jsonResult as Map<String, dynamic>).entries) {
        rolls.add(Roll.fromJson(entry));
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
                            rolls.add(Roll(activity["Name"], true, {}, ids));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
        );
  }

  bool rollExists(String rollname) {
    return rolls.map((e) => e.title).contains(rollname);
  }

  Roll getRoll(String rollname) {
    return rolls.firstWhere((element) => element.title == rollname);
  }

  void createRoll(
    String rollname, {
    bool synced = false,
    Set<String>? expected,
  }) {
    rolls.add(Roll(
      rollname,
      synced,
      {},
      expected ?? {},
    ));
  }

  void updateRoll(
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
  }

  Set<String> getAttendees(String rollname) {
    return rollExists(rollname) ? getRoll(rollname).attended : {};
  }

  Set<String> getExpectedAttendees(String rollname) {
    return rollExists(rollname) ? getRoll(rollname).expected : {};
  }

  Set<String> getCadetsAway(String rollname) {
    return getExpectedAttendees(rollname)
        .difference(getAttendees(rollname))
        .map((e) => UserMappings.getName(e))
        .where((element) => element != "")
        .toSet();
  }

  bool isRollSynced(String rollname) {
    return rollExists(rollname) ? getRoll(rollname).synced : false;
  }
}
