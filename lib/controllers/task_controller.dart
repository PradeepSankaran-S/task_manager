import 'package:get/get.dart';

import '../app/constants/app_constants.dart';
import '../app/constants/app_strings.dart';
import '../data/models/task_filter.dart';
import '../data/models/task_model.dart';
import '../data/models/task_priority.dart';
import '../data/storage/task_storage.dart';

class TaskController extends GetxController {
  TaskController({TaskStorage? storage}) : _storage = storage ?? TaskStorage();

  final TaskStorage _storage;

  final tasks = <TaskModel>[].obs;
  final filter = TaskFilter.all.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  List<TaskModel> get filteredTasks {
    switch (filter.value) {
      case TaskFilter.pending:
        return tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
        return List<TaskModel>.from(tasks);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getTasks();
  }

  void getTasks() {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final loadedTasks = _storage.loadTasks();
      tasks.assignAll(_sorted(loadedTasks));
    } catch (_) {
      errorMessage.value = AppStrings.loadError;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    final task = TaskModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    return _persist([...tasks, task], successMessage: AppStrings.taskAdded);
  }

  Future<bool> updateTask(TaskModel updatedTask) {
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) {
      errorMessage.value = AppStrings.notFound;
      return Future.value(false);
    }

    final next = List<TaskModel>.from(tasks);
    next[index] = updatedTask.copyWith(title: updatedTask.title.trim());
    return _persist(next, successMessage: AppStrings.taskUpdated);
  }

  Future<bool> deleteTask(String id) {
    final next = tasks.where((task) => task.id != id).toList();
    if (next.length == tasks.length) {
      errorMessage.value = AppStrings.notFound;
      return Future.value(false);
    }

    return _persist(
      next,
      successMessage: AppStrings.taskDeleted,
      errorFallback: AppStrings.deleteError,
    );
  }

  Future<bool> toggleTaskStatus(String id) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      errorMessage.value = AppStrings.notFound;
      return Future.value(false);
    }

    final next = List<TaskModel>.from(tasks);
    next[index] = next[index].copyWith(isCompleted: !next[index].isCompleted);
    return _persist(next);
  }

  void filterTasks(TaskFilter value) {
    filter.value = value;
  }

  TaskModel? findTask(String id) {
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _persist(
    List<TaskModel> next, {
    String? successMessage,
    String errorFallback = AppStrings.saveError,
  }) async {
    errorMessage.value = '';

    try {
      final sorted = _sorted(next);
      await _storage.saveTasks(sorted);
      tasks.assignAll(sorted);
      if (successMessage != null) {
        Get.snackbar(
          AppConstants.appName,
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return true;
    } catch (_) {
      errorMessage.value = errorFallback;
      Get.snackbar(
        'Something went wrong',
        errorFallback,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  List<TaskModel> _sorted(List<TaskModel> source) {
    final copy = List<TaskModel>.from(source);
    copy.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final dueDateCompare = a.dueDate.compareTo(b.dueDate);
      if (dueDateCompare != 0) return dueDateCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return copy;
  }
}
