import 'package:cadets/Rolls/roll.dart';
import 'package:flutter/material.dart';
import 'scanner.dart';
import 'roll_view.dart';
import 'search.dart';

class ActivityHome extends StatefulWidget {
  final Roll roll;

  const ActivityHome({Key? key, required this.roll}) : super(key: key);

  @override
  State<ActivityHome> createState() => _ActivityHomeState();
}

class _ActivityHomeState extends State<ActivityHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(),
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
