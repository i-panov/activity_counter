import 'package:activity_counter/helpers.dart';
import 'package:activity_counter/models.dart';
import 'package:activity_counter/repositories.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';

class ActivitiesProvider extends ValueNotifier<ISet<Activity>> {
  final ActivitiesRepository repository;

  ActivitiesProvider({required this.repository}): super(const ISet.empty());

  Future<void> load() async => value = await repository.getActivities();

  Future<void> save() async => await repository.saveActivities(value);

  void addByName(String name) {
    value = value.add(Activity(name: name));
    save();
  }

  void removeAt(int index) {
    value = value.mapIndexedAndLast((i, a, _) => i == index ? null : a).whereType<Activity>().toISet();
    save();
  }

  void changeName(int index, String name) {
    value = value.replaceAt(index, (a) => Activity(name: name, history: a.history)).toISet();
    save();
  }

  void clearHistory(int index) {
    value = value.replaceAt(index, (a) => Activity(name: a.name, history: const ISet.empty())).toISet();
    save();
  }

  void addHistoryEntry(int index, HistoryEntry entry) {
    value = value.replaceAt(index, (a) => Activity(name: a.name, history: a.history.add(entry))).toISet();
    save();
  }
}
