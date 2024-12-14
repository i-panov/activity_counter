import 'dart:math';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

enum HistoryEntryType { lesson, purchase }

sealed class HistoryEntry {
  final HistoryEntryType type;
  final DateTime time;

  const HistoryEntry({
    required this.type, 
    required this.time,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    final type = HistoryEntryType.values.byName(json['type']);
    final time = DateTime.parse(json['time']);

    return switch (type) {
      HistoryEntryType.lesson => LessonHistoryEntry(time: time),
      HistoryEntryType.purchase => PurchaseHistoryEntry(time: time, count: json['count']),
    };
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'time': time.toIso8601String(),
  };
}

class LessonHistoryEntry extends HistoryEntry {
  const LessonHistoryEntry({
    required super.time,
  }): super(type: HistoryEntryType.lesson);
}

class PurchaseHistoryEntry extends HistoryEntry {
  final int count;

  const PurchaseHistoryEntry({
    required super.time,
    required this.count,
  }): super(type: HistoryEntryType.purchase);

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'count': count,
  };
}

class Activity {
  final String name;
  final ISet<HistoryEntry> history;

  const Activity({
    required this.name,
    this.history = const ISet.empty(),
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    name: json['name'],
    history: ISet.fromJson(json['history'], (e) => HistoryEntry.fromJson(e as Map<String, dynamic>)),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'history': history.map((e) => e.toJson()).toList(),
  };

  int get passedLessonsCount => history.whereType<LessonHistoryEntry>().length;

  int get purchasedLessonsCount => history.whereType<PurchaseHistoryEntry>().sumBy((e) => e.count);

  int get leftLessonsCount => max(0, purchasedLessonsCount - passedLessonsCount);
}
