import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Elapsed time since a target date, split into calendar units.
class TimeBreakdown {
  final int years, months, days, hours, minutes, seconds;

  const TimeBreakdown({
    this.years = 0,
    this.months = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  });

  /// Computes the breakdown between [target] and [now]. Returns zeros when
  /// [target] is null or in the future.
  factory TimeBreakdown.between(DateTime? target, DateTime now) {
    if (target == null || !now.isAfter(target)) return const TimeBreakdown();

    int years = now.year - target.year;
    int months = now.month - target.month;
    int days = now.day - target.day;
    int hours = now.hour - target.hour;
    int minutes = now.minute - target.minute;
    int seconds = now.second - target.second;

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

    return TimeBreakdown(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }
}

class TimeCounter extends StatefulWidget {
  final DateTime? targetDate;

  const TimeCounter({required this.targetDate, super.key});

  @override
  TimeCounterState createState() => TimeCounterState();
}

class TimeCounterState extends State<TimeCounter> {
  Timer? timer;
  TimeBreakdown _breakdown = const TimeBreakdown();

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _breakdown = TimeBreakdown.between(widget.targetDate, DateTime.now());
    });
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
          TimeColumn(label: 'ans', value: '${_breakdown.years}'),
          TimeColumn(label: 'mois', value: '${_breakdown.months}'),
          TimeColumn(label: 'jours', value: '${_breakdown.days}'),
          TimeColumn(label: 'heures', value: '${_breakdown.hours}'),
          TimeColumn(label: 'min', value: '${_breakdown.minutes}'),
          TimeColumn(label: 'sec', value: '${_breakdown.seconds}', isLast: true),
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
                style: TextStyle(
                  fontSize: 100.sp,
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
