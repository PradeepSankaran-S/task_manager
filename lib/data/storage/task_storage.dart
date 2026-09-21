import 'package:get_storage/get_storage.dart';

import '../../app/constants/app_constants.dart';
import '../models/task_model.dart';

class TaskStorage {
  TaskStorage({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  List<TaskModel> loadTasks() {
    final stored = _box.read<List<dynamic>>(AppConstants.tasksStorageKey);
    if (stored == null) return [];

    return stored
        .whereType<Map>()
        .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item)))
        .where((task) => task.id.isNotEmpty && task.title.isNotEmpty)
        .toList();
  }

  Future<void> saveTasks(List<TaskModel> tasks) {
    final payload = tasks.map((task) => task.toJson()).toList();
    return _box.write(AppConstants.tasksStorageKey, payload);
  }
}
