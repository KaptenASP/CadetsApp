import 'package:cadets/Helpers/file_helper.dart';
import 'package:cadets/Constants/cadetnet_api.dart';
import '../Helpers/network_helper.dart';
import 'user_mappings.dart';

class Roll {
  final String title;
  final int activityId;
  String _date;
  bool _synced;
  final Set<String> _attended;
  final Set<String> _expected;

  Roll(this.title, this.activityId, this._date, this._synced, this._attended,
      this._expected);

  void updateRoll({
    bool? synced,
    String? date,
    Set<String>? attended,
    Set<String>? expected,
  }) {
    _date = date!;
    _synced = synced!;
    _attended.addAll(attended ?? {});
    _expected.addAll(expected ?? {});
  }

  bool get synced => _synced;
  String get date => _date;
  Set<String> get attended => _attended;
  Set<String> get expected => _expected;
  Set<String> get absent => _expected.difference(_attended);

  void addAttendee(String cadet) {
    _attended.add(cadet);
  }

  void removeAttendee(String cadet) {
    _attended.remove(cadet);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': _date,
        'id': activityId,
        'synced': _synced,
        'attended': attended.toList(),
        'expected': _expected.toList(),
      };

  static Roll fromJson(MapEntry<String, dynamic> json) => Roll(
        json.key,
        json.value['id'] as int,
        json.value['date'] as String,
        json.value['synced'] as bool,
        Set<String>.from(json.value['attended']),
        Set<String>.from(json.value['expected']),
      );
}

class RollManager {
  static int _rollId = 0;
  static final List<Roll> _rolls = [];
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
                            // print roll name
                            String startDate = activity["StartDate"] ??
                                DateTime.now().toIso8601String().split("T")[0];

                            // Add member to roll
                            if (rollExists(activity["Id"])) {
                              updateRoll(activity["Id"],
                                  rollname: activity["Name"],
                                  date: startDate,
                                  synced: true,
                                  expected: ids);
                            } else {
                              addRoll(
                                Roll(
                                  activity["Name"],
                                  activity["Id"],
                                  startDate,
                                  true,
                                  {},
                                  ids,
                                ),
                              );
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

    _rolls.sort((a, b) => a.date.compareTo(b.date));
  }

  static int getNextActivityId() {
    List<int> ids = _rolls.map((e) => e.activityId).toList();
    while (ids.contains(_rollId)) {
      _rollId++;
    }

    return _rollId;
  }

  static void saveRolls() {
    Map<String, dynamic> json = {};

    for (var roll in _rolls) {
      json.addAll({roll.title: roll.toJson()});
    }

    writeJsonData(json, "rolls");
  }

  static bool rollExists(int activityId) {
    return _rolls.map((e) => e.activityId).contains(activityId);
  }

  static Roll getRoll(int activityId) {
    return _rolls.firstWhere((element) => element.activityId == activityId);
  }

  static void createRoll(
    String rollname, {
    bool synced = false,
    Set<String>? expected,
  }) {
    addRoll(
      Roll(
        rollname,
        getNextActivityId(),
        DateTime.now().toIso8601String().split("T")[0],
        false,
        {},
        expected ?? UserMappings.getAllIds(),
      ),
    );
    _rollId++;
    saveRolls();
  }

  static void updateRoll(
    int activityId, {
    String? rollname,
    String? date,
    bool? synced,
    Set<String>? attended,
    Set<String>? expected,
  }) {
    getRoll(activityId).updateRoll(
      date: date,
      synced: synced,
      attended: attended,
      expected: expected,
    );
  }

  static void deleteRoll(String rollname) {
    _rolls.removeWhere((element) => element.title == rollname);
    saveRolls();
  }

  static void addRoll(Roll roll) {
    // Add the roll to the list using insert so that it is sorted
    if (_rolls.contains(roll)) {
      return;
    }

    if (_rolls.isEmpty) {
      _rolls.add(roll);
      return;
    }

    _rolls.insert(
      _rolls.indexWhere((element) => element.date.compareTo(roll.date) > 0),
      roll,
    );
  }

  static List<Roll> get rolls => _rolls;
}
