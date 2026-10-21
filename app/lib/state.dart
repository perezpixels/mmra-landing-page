import 'dart:async';

import 'package:flutter/widgets.dart';

import 'data.dart';

/// Prototype state for one visit, mirroring `AppStateProvider` in WebApp.tsx.
class AppState extends ChangeNotifier {
  final List<String> saved = [];
  List<PlanItem> plan = List.of(initialPlan);
  String toast = '';
  bool completedPractice = false;
  Timer? _toastTimer;
  int _planCounter = 0;

  void showToast(String message) {
    toast = message;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2600), () {
      toast = '';
      notifyListeners();
    });
    notifyListeners();
  }

  bool isSaved(String id) => saved.contains(id);

  void toggleSaved(String id, String title) {
    final removing = saved.contains(id);
    showToast(removing
        ? 'Removed “$title” from your reading list.'
        : 'Saved “$title” to your reading list.');
    if (removing) {
      saved.remove(id);
    } else {
      saved.add(id);
    }
    notifyListeners();
  }

  void addPlan({
    required String type,
    required String title,
    required String date,
    required String duration,
  }) {
    _planCounter++;
    plan = [
      ...plan,
      PlanItem(
        id: 'plan-${DateTime.now().millisecondsSinceEpoch}-$_planCounter',
        type: type,
        title: title,
        date: date,
        duration: duration,
        done: false,
      ),
    ];
    showToast('Study session added. This prototype stores changes only for this visit.');
  }

  void togglePlan(String id) {
    plan = [
      for (final item in plan) item.id == id ? item.copyWith(done: !item.done) : item,
    ];
    showToast('Study plan updated.');
  }

  void setCompletedPractice(bool value) {
    completedPractice = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
