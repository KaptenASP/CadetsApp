import 'dart:io';

import 'package:cadets/Helpers/file_helper.dart';
import 'package:cadets/Constants/cadetnet_api.dart';
import '../Helpers/network_helper.dart';
import 'user_mappings.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Roll {
  static DateFormat format = DateFormat('dd MMM yyyy');

  String title;
  final int activityId;
  DateTime _date;
  bool _synced;
  final Set<String> _attended;
  final Set<String> _expected;

  Roll(this.title, this.activityId, this._date, this._synced, this._attended,
      this._expected);

  void updateRoll({
    String? title,
    bool? synced,
    DateTime? date,
    Set<String>? attended,
    Set<String>? expected,
  }) {
    title = title!;
    _date = date!;
    _synced = synced!;
    _attended.addAll(attended ?? {});
    _expected.addAll(expected ?? {});
  }

  bool get synced => _synced;
  DateTime get date => _date;
  String get dateString => format.format(_date);
  Set<String> get attended => _attended;
  Set<String> get expected => _expected;
  Set<String> get absent => _expected.difference(_attended);

  void addAttendee(String cadet) {
    _attended.add(cadet);
    RollManager.saveRolls();
  }

  void removeAttendee(String cadet) {
    _attended.remove(cadet);
    RollManager.saveRolls();
  }

  /// Marks the roll and sends it to cadetnet
  /// @precondition: The roll is synced and the user is logged in to cadetnet
  /// @postcondition: The roll is marked and sent to cadetnet
  void markRoll(Map<dynamic, dynamic> data) {
    int numAttended = 0;
    int numLeave = 0;
    int unmarked = 0;

    for (Map<dynamic, dynamic> element in data["Entries"]) {
      if (_attended.contains('${element["Attendee"]["Member"]["UID"]}')) {
        element["Present"] = true;
        element["Reason"] = null;
        element["checked"] = false;
        numAttended++;
      } else if (_expected
          .contains('${element["Attendee"]["Member"]["UID"]}')) {
        element["Present"] = false;
        element["Reason"] = null;
        numLeave++;
      } else {
        element["Present"] = null;
        unmarked++;
      }

      element["AttendeeId"] = element["Attendee"]["Id"];
    }

    data['RollMarkedById'] = 4177131;
    data['RollTime'] = "19:00";
    data['Attended'] = numAttended;
    data['Absent'] = numLeave;
    data['Unmarked'] = unmarked;
    data['RollMarked'] = DateTime.now().toIso8601String().split('T')[0];

    APIPostRequest request = CadetnetApi.saveNominalRoll(data);
    Session session = Session.instance;
    session.saveNominalRoll(request);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': _date.toIso8601String(),
        'id': activityId,
        'synced': _synced,
        'attended': attended.toList(),
        'expected': _expected.toList(),
      };

  static Roll fromJson(MapEntry<String, dynamic> json) => Roll(
        json.value['title'] as String,
        json.value['id'] as int,
        DateTime.parse(json.value['date']),
        json.value['synced'] as bool,
        Set<String>.from(json.value['attended']),
        Set<String>.from(json.value['expected']),
      );

  void toPdf() async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 30,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Header(
            level: 1,
            child: pw.Text(dateString),
          ),
          pw.TableHelper.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Name', 'ID', 'Present'],
              ...expected.map((e) => [
                    UserMappings.getName(e),
                    e,
                    '',
                  ]),
            ],
          ),
        ];
      },
    ));

    // Save the file

    final file = File("example.pdf");
    await file.writeAsBytes(await pdf.save());
  }
}

class RollManager {
  static int _rollId = 0;
  static final List<Roll> _rolls = [];
  static final Session session = Session.instance;
  static const String savePath = "rolls";

  RollManager() {
    loadFromStorage(savePath).then((value) {
      if (value == null) {
        return;
      }

      for (MapEntry<String, dynamic> entry in value.entries) {
        _rolls.add(Roll.fromJson(entry));
      }
    });

    syncOnline();

    _rolls.sort((a, b) => a.date.compareTo(b.date));
  }

  static Future<void> syncOnline() async {
    bool loggedInCheck = await session.checkLogin();

    if (!loggedInCheck) {
      return;
    }

    Map<dynamic, dynamic> activities = await session.getActivities();

    for (var activity in activities["DataList"]) {
      Map<dynamic, dynamic> memberValues = await session.getActivityAttendees(
          CadetnetApi.postActivityAttendees(activity["Id"] as int));

      Set<String> ids = {};

      memberValues["DataList"].forEach((member) {
        ids.add("${member['Member']['MemberDisplay'].split(' - ')[1]}");
      });

      DateTime startDate = DateTime.parse(activity["StartDate"]);

      if (rollExists(activity["Id"])) {
        updateRoll(
          activity["Id"],
          rollname: activity["Name"],
          date: startDate,
          synced: true,
          expected: ids,
        );
      } else {
        addRoll(
          Roll(activity["Name"], activity["Id"], startDate, true, {}, ids),
        );
      }
    }

    saveRolls();
  }

  static int getNextActivityId() {
    List<int> ids = _rolls.map((e) => e.activityId).toList();
    while (ids.contains(_rollId)) {
      _rollId++;
    }

    return _rollId;
  }

  static void saveRolls() {
    Map<String, dynamic> r = {};

    for (var roll in _rolls) {
      r.addAll({'${roll.activityId}': roll.toJson()});
    }

    saveToStorage(savePath, r);
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
        DateTime.now(),
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
    DateTime? date,
    bool? synced,
    Set<String>? expected,
  }) {
    getRoll(activityId).updateRoll(
      title: rollname,
      date: date,
      synced: synced,
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

    int idx =
        _rolls.indexWhere((element) => element.date.compareTo(roll.date) > 0);

    if (idx == -1) {
      _rolls.add(roll);
      return;
    }

    _rolls.insert(
      idx,
      roll,
    );
  }

  static List<Roll> get rolls => _rolls;
}
