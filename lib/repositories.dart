import 'package:activity_counter/models.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

abstract class ActivitiesRepository {
  Future<ISet<Activity>> getActivities();

  Future<void> saveActivities(Iterable<Activity> activities);
}

class InMemoryActivitiesRepository implements ActivitiesRepository {
  var _data = const ISet<Activity>.empty();

  @override
  Future<ISet<Activity>> getActivities() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _data;
  }

  @override
  Future<void> saveActivities(Iterable<Activity> activities) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _data = activities.toISet();
  }
}
