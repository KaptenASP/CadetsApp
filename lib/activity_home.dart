import 'package:cadets/Constants/cadetnet_api.dart';
import 'package:cadets/Helpers/network_helper.dart';
import 'package:cadets/Rolls/roll.dart';
import 'package:cadets/Rolls/user_mappings.dart';
import 'package:flutter/material.dart';
import 'scanner.dart';
import 'roll_view.dart';
import 'search.dart';
import 'dart:convert';

class ActivityHome extends StatefulWidget {
  final Roll roll;

  const ActivityHome({Key? key, required this.roll}) : super(key: key);

  @override
  State<ActivityHome> createState() => _ActivityHomeState();
}

class _ActivityHomeState extends State<ActivityHome> {
  TextEditingController rollNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Enter term and week'),
                content: TextFormField(
                  controller: rollNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter 1 1 for Term 1 Week 1',
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
                      // createRoll(rollNameController.text);
                      List<String> termWeek =
                          rollNameController.text.split(" ");

                      int term = int.parse(termWeek[0]);
                      int week = int.parse(termWeek[1]);

                      Session session = Session.instance;
                      session
                          .getAttendeesFromSheets(
                              CadetnetApi.getAttendeeesFromSheets(term, week))
                          .then((value) {
                        List<dynamic> result = json.decode(value["result"]);

                        for (var element in result) {
                          if (UserMappings.getName('$element') == '') {
                            continue;
                          }

                          widget.roll.addAttendee('$element');
                        }

                        RollManager.saveRolls();

                        setState(() {});
                      });

                      Navigator.pop(context, 'OK');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: const Text('Sync Sheets'),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            // 'Extended' app bar
            color: const Color(0xff010409),
            padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            child: Column(
              children: [
                Text(
                  // Name of activity
                  widget.roll.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Row(
                  // Sync status of the activity
                  children: [
                    const Icon(Icons.sync_alt_outlined,
                        color: Color(0xff8e8e8e)),
                    Text(
                      widget.roll.synced ? "Synced" : "Not Synced",
                      style: const TextStyle(
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ],
                ),
                Row(
                  // Date for the activity
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xff8e8e8e)),
                    Text(
                      widget.roll.dateString,
                      style: const TextStyle(
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ],
                )
              ]
                  .map(
                    // Align all widgets to top left and add padding
                    (widget) => Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: widget,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Roll Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            children: [
              Card(
                // Open up the scanner page when tapped
                elevation: 0,
                color: const Color(0xff0d1117),
                child: InkWell(
                  onTap: () {
                    Session session = Session.instance;
                    // APIGetRequest getGroups, String activityName
                    APIGetRequest getGroups =
                        CadetnetApi.getRollGroups(widget.roll.activityId);
                    session
                        .getNominalRoll(getGroups, widget.roll.title)
                        .then((value) => widget.roll.markRoll(value["Data"]));
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Color(0xff2ea043),
                      ),
                      Text("  Submit Roll"),
                    ],
                  ),
                ),
              ),
              Card(
                // Open up the scanner page when tapped
                elevation: 0,
                color: const Color(0xff0d1117),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scanner(
                          roll: widget.roll,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Color(0xff2ea043),
                      ),
                      Text("  Scanner"),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: const Color(0xff0d1117),
                child: InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => SearchCadet(
                      roll: widget.roll,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Color(0xfff1e05a),
                      ),
                      Text("  Search"),
                    ],
                  ),
                ),
              ),
            ]
                .map((widget) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: widget,
                    ))
                .toList(),
          ),
          const Divider(
            color: Color(0xff30363d),
            thickness: 1,
          ),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Card(
                  elevation: 0,
                  color: const Color(0xff0d1117),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RollView(
                            strategy: AttendedStrategy(widget.roll),
                          ),
                        ),
                      );
                    },
                    child: Align(
                      child: Column(
                        // Widget to show cadets attended.
                        // Opens up page with all cadets once tapped.
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, color: Color(0xff2ea043)),
                          const Text("Attended",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                          Text(widget.roll.attended.length.toString()),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  // Widget to show cadets absent but expected.
                  // Opens up page with these cadets once tapped.
                  elevation: 0,
                  color: const Color(0xff0d1117),
                  // onclick oopen roll view
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RollView(
                            strategy: AbsentStrategy(widget.roll),
                          ),
                        ),
                      );
                    },
                    child: Align(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, color: Color(0xff2ea043)),
                          const Text(
                            "Absent",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(widget.roll.absent.length.toString())
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  // Widget to show all expected cadets.
                  // Opens up page with these cadets once tapped.
                  elevation: 0,
                  color: const Color(0xff0d1117),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RollView(
                            strategy: ExpectedStrategy(widget.roll),
                          ),
                        ),
                      );
                    },
                    child: Align(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.all_inclusive,
                              color: Color(0xff2ea043)),
                          const Text(
                            "Expected",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(widget.roll.expected.length.toString())
                        ],
                      ),
                    ),
                  ),
                ),
              ]
                  .map((e) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          // Add curved edges
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xff30363d),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 200,
                          child: e,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
