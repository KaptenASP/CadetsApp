import 'package:cadets/Rolls/user_mappings.dart';
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
  Roll roll;

  AttendedStrategy(this.roll);

  @override
  Set<String> get cadets =>
      roll.attended.map((e) => UserMappings.getName(e)).toSet();
}

class AbsentStrategy implements CadetListStrategy {
  Roll roll;

  AbsentStrategy(this.roll);

  @override
  Set<String> get cadets =>
      roll.absent.map((e) => UserMappings.getName(e)).toSet();
}

class ExpectedStrategy implements CadetListStrategy {
  Roll roll;

  ExpectedStrategy(this.roll);

  @override
  Set<String> get cadets =>
      roll.expected.map((e) => UserMappings.getName(e)).toSet();
}
