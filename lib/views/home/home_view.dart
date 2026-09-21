import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/constants/app_strings.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/task_controller.dart';
import '../../data/models/task_filter.dart';
import '../../data/models/task_model.dart';
import '../../widgets/app_max_width.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_filter_bar.dart';

class HomeView extends GetView<TaskController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addTask),
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.tasks.isEmpty) {
            return EmptyState(
              title: 'Unable to load tasks',
              message: controller.errorMessage.value,
              actionLabel: AppStrings.retry,
              onAction: controller.getTasks,
            );
          }

          return AppMaxWidth(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TaskFilterBar(
                      selected: controller.filter.value,
                      onChanged: controller.filterTasks,
                    ),
                  ),
                ),
                Expanded(child: _TaskList(controller: controller)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.filteredTasks;

    if (items.isEmpty) {
      return EmptyState(
        title: _emptyTitle(controller.filter.value, controller.tasks.isEmpty),
        message: _emptyMessage(
          controller.filter.value,
          controller.tasks.isEmpty,
        ),
        actionLabel: controller.tasks.isEmpty ? AppStrings.addTask : null,
        onAction: controller.tasks.isEmpty
            ? () => Get.toNamed(AppRoutes.addTask)
            : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = items[index];
        return TaskCard(
          task: task,
          onTap: () => Get.toNamed(
            AppRoutes.taskDetails,
            arguments: task.id,
          ),
          onToggleStatus: () => controller.toggleTaskStatus(task.id),
          onEdit: () => Get.toNamed(AppRoutes.addTask, arguments: task),
          onDelete: () => _deleteTask(context, task),
        );
      },
    );
  }

  Future<void> _deleteTask(BuildContext context, TaskModel task) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage,
    );
    if (confirmed) {
      await controller.deleteTask(task.id);
    }
  }

  String _emptyTitle(TaskFilter filter, bool noTasksAtAll) {
    if (noTasksAtAll) return AppStrings.emptyAllTitle;
    switch (filter) {
      case TaskFilter.pending:
        return AppStrings.emptyPendingTitle;
      case TaskFilter.completed:
        return AppStrings.emptyCompletedTitle;
      case TaskFilter.all:
        return AppStrings.emptyAllTitle;
    }
  }

  String _emptyMessage(TaskFilter filter, bool noTasksAtAll) {
    if (noTasksAtAll) return AppStrings.emptyAllMessage;
    switch (filter) {
      case TaskFilter.pending:
        return AppStrings.emptyPendingMessage;
      case TaskFilter.completed:
        return AppStrings.emptyCompletedMessage;
      case TaskFilter.all:
        return AppStrings.emptyAllMessage;
    }
  }
}
