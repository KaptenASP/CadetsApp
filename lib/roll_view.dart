import 'package:flutter/material.dart';
import 'package:cadets/Rolls/roll.dart';

class RollView extends StatefulWidget {
  final CadetListStrategy strategy;
  const RollView({
    Key? key,
    required this.strategy,
  }) : super(key: key);

  @override
  State<RollView> createState() => _RollViewState();
}

class _RollViewState extends State<RollView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(),
      // Add a card for each member in the activity roll
      body: ListView(
        children: widget.strategy.cadets
            .map(
              (e) => Container(
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xff30363d),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(e),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

abstract class CadetListStrategy {
  Set<String> get cadets;
}

class AttendedStrategy implements CadetListStrategy {
  String rollname;
  String date;

  AttendedStrategy(this.rollname, this.date);

  @override
  Set<String> get cadets => RollManager.getAttendees(rollname, date);
}

class AbsentStrategy implements CadetListStrategy {
  String rollname;
  String date;

  AbsentStrategy(this.rollname, this.date);

  @override
  Set<String> get cadets => RollManager.getCadetsAway(rollname);
}

class ExpectedStrategy implements CadetListStrategy {
  String rollname;
  String date;

  ExpectedStrategy(this.rollname, this.date);

  @override
  Set<String> get cadets => RollManager.getExpectedAttendees(rollname, date);
}
