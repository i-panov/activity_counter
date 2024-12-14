import 'package:activity_counter/models.dart';
import 'package:activity_counter/providers.dart';
import 'package:activity_counter/repositories.dart';
import 'package:activity_counter/widgets.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const ActivityCounterApp());
}

class ActivityCounterApp extends StatelessWidget {
  const ActivityCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActivitiesProvider(
        repository: InMemoryActivitiesRepository()
      ),
      child: MaterialApp(
        title: 'Счетчик абонементов',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ActivitiesListPage(),
      ),
    );
  }
}

class ActivitiesListPage extends StatelessWidget {
  const ActivitiesListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivitiesProvider>();
    final activities = provider.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Абонементы'),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];

          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${activity.purchasedLessonsCount} куплено'),
                Text('${activity.passedLessonsCount} пройдено'),
                Text('${activity.leftLessonsCount} осталось'),
              ],
            ),
            title: Text(activity.name),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailPage(
              activity: activity,
              activityIndex: index,
            ))),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final name = await getActivityName(context, initialValue: activity.name);

                    if (name != null && name.isNotEmpty) {
                      provider.changeName(index, name);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.removeAt(index),
                ),
              ],
            ),
          );
        }
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () async {
          final name = await getActivityName(context);

          if (name != null && name.isNotEmpty) {
            provider.addByName(name);
          }
        },
      ),
    );
  }
}

class ActivityDetailPage extends StatelessWidget {
  final Activity activity;
  final int activityIndex;

  const ActivityDetailPage({
    super.key,
    required this.activity,
    required this.activityIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ActivitiesProvider>();
    final history = context.select<ActivitiesProvider, ISet<HistoryEntry>>((p) => p.value[activityIndex].history);

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index];

          return ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('E, dd.MM.yyyy', 'ru_RU').format(entry.time)),
                Text(DateFormat.Hm().format(entry.time)),
              ],
            ),
            title: switch (entry.type) {
              HistoryEntryType.lesson => const Text('Занятие'),
              HistoryEntryType.purchase => const Text('Покупка занятий'),
            },
            subtitle: switch (entry) {
              LessonHistoryEntry() => null,
              PurchaseHistoryEntry(count: final count) => Text('$count шт.'),
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //provider.addHistoryEntry(activityIndex, PurchaseHistoryEntry(time: DateTime.now(), count: 1));

          getHistoryEntry(context);
        },
      ),
    );
  }
}

Future<String?> getActivityName(BuildContext context, {String? initialValue}) async {
  final formKey = GlobalKey<FormState>();
  final ctrl = TextEditingController(text: initialValue);

  return showAdaptiveDialog(context: context, builder: (context) => Form(
    key: formKey,
    child: AlertDialog(
      title: const Text('Название абонемента'),
      content: TextFormField(
        controller: ctrl,
        validator: (v) => v == null || v.isEmpty ? 'Введите название' : null,
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, ctrl.text);
            }
          },
        ),
        TextButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  ));
}

Future<HistoryEntry?> getHistoryEntry(BuildContext context) async {
  final typeHolder = ValueNotifier(HistoryEntryType.lesson);

  return showAdaptiveDialog(context: context, builder: (context) => AlertDialog(
    title: const Text('Добавить запись'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DateFormField(),
        DropdownMenu<HistoryEntryType>(
          initialSelection: typeHolder.value,
          onSelected: (value) {
            if (value != null) {
              typeHolder.value = value;
            }
          },
          dropdownMenuEntries: HistoryEntryType.values.map((type) => DropdownMenuEntry(
            value: type,
            label: switch (type) {
              HistoryEntryType.lesson => 'Занятие',
              HistoryEntryType.purchase => 'Покупка занятий',
            },
          )).toList(),
        ),
        ValueListenableBuilder(
          valueListenable: typeHolder, 
          builder: (context, type, _) => switch (type) {
            HistoryEntryType.purchase => Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Количество'),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Введите количество';
                  }

                  if (int.tryParse(v) == null) {
                    return 'Введите число';
                  }

                  return null;
                },
              ),
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    ),
  ));
}
