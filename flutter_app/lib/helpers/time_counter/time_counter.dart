import 'dart:async';
import 'package:flutter/material.dart';

class TimeCounter extends StatefulWidget {
  final DateTime? targetDate;

  const TimeCounter({required this.targetDate, super.key});

  @override
  TimeCounterState createState() => TimeCounterState();
}

class TimeCounterState extends State<TimeCounter> {
  String timeDifference = '';
  Timer? timer;
  int years = 0, months = 0, days = 0, hours = 0, minutes = 0, seconds = 0;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _updateTime();
  }

  void _updateTime() {
    final now = DateTime.now();
    if (widget.targetDate != null && now.isAfter(widget.targetDate!)) {
      DateTime target = widget.targetDate!;

      years = now.year - target.year;
      months = now.month - target.month;
      days = now.day - target.day;
      hours = now.hour - target.hour;
      minutes = now.minute - target.minute;
      seconds = now.second - target.second;

      if (seconds < 0) {
        seconds += 60;
        minutes -= 1;
      }

      if (minutes < 0) {
        minutes += 60;
        hours -= 1;
      }

      if (hours < 0) {
        hours += 24;
        days -= 1;
      }

      if (days < 0) {
        days += DateTime(now.year, now.month, 0).day;
        months -= 1;
      }

      if (months < 0) {
        months += 12;
        years -= 1;
      }

      setState(() {});
    } else {
      setState(() {
        years = 0;
        months = 0;
        days = 0;
        hours = 0;
        minutes = 0;
        seconds = 0;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TimeColumn(label: 'ans', value: '$years'),
          TimeColumn(label: 'mois', value: '$months'),
          TimeColumn(label: 'jours', value: '$days'),
          TimeColumn(label: 'heures', value: '$hours'),
          TimeColumn(label: 'min', value: '$minutes'),
          TimeColumn(label: 'sec', value: '$seconds', isLast: true),
        ],
      ),
    );
  }
}

class TimeColumn extends StatelessWidget {
  final String value;
  final String label;
  final bool isLast;

  const TimeColumn({
    super.key,
    required this.value,
    required this.label,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    String paddedValue = value.padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 0),
              child: Text(
                paddedValue,
                key: ValueKey<String>(paddedValue),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            )
          ],
        ),
        if (!isLast) const SizedBox(width: 12),
      ],
    );
  }
}
