enum ReminderFrequency {
  daily,
  weekly,
  biweekly,
}

class B12ReminderSettings {
  bool enabled;
  ReminderFrequency frequency;
  int hour; // 0-23
  int minute; // 0-59
  int? dayOfWeek; // 1-7 (Monday = 1, Sunday = 7), null for daily

  B12ReminderSettings({
    this.enabled = false,
    this.frequency = ReminderFrequency.daily,
    this.hour = 9,
    this.minute = 0,
    this.dayOfWeek = 1, // Default to Monday
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'frequency': frequency.index,
      'hour': hour,
      'minute': minute,
      'dayOfWeek': dayOfWeek,
    };
  }

  // Create from JSON
  factory B12ReminderSettings.fromJson(Map<String, dynamic> json) {
    return B12ReminderSettings(
      enabled: json['enabled'] ?? false,
      frequency: ReminderFrequency.values[json['frequency'] ?? 1],
      hour: json['hour'] ?? 9,
      minute: json['minute'] ?? 0,
      dayOfWeek: json['dayOfWeek'],
    );
  }

  // Get a user-friendly description of the reminder
  String getDescription() {
    if (!enabled) return 'Désactivé';

    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    switch (frequency) {
      case ReminderFrequency.daily:
        return 'Tous les jours à $timeStr';
      case ReminderFrequency.weekly:
        final dayName = _getDayName(dayOfWeek ?? 1);
        return 'Chaque $dayName à $timeStr';
      case ReminderFrequency.biweekly:
        final dayName = _getDayName(dayOfWeek ?? 1);
        return 'Toutes les deux semaines le $dayName à $timeStr';
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'lundi';
      case 2:
        return 'mardi';
      case 3:
        return 'mercredi';
      case 4:
        return 'jeudi';
      case 5:
        return 'vendredi';
      case 6:
        return 'samedi';
      case 7:
        return 'dimanche';
      default:
        return 'lundi';
    }
  }

  B12ReminderSettings copyWith({
    bool? enabled,
    ReminderFrequency? frequency,
    int? hour,
    int? minute,
    Object? dayOfWeek = _undefined,
  }) {
    return B12ReminderSettings(
      enabled: enabled ?? this.enabled,
      frequency: frequency ?? this.frequency,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      dayOfWeek: identical(dayOfWeek, _undefined)
          ? this.dayOfWeek
          : (dayOfWeek as int?),
    );
  }
}

// Sentinel value for optional parameters in copyWith
const Object _undefined = Object();
