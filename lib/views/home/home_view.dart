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
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addTask),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addTask),
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
              icon: Icons.error_outline_rounded,
              actionLabel: AppStrings.retry,
              actionIcon: Icons.refresh_rounded,
              onAction: controller.getTasks,
            );
          }

          final pendingCount = controller.tasks
              .where((task) => !task.isCompleted)
              .length;
          final completedCount = controller.tasks.length - pendingCount;

          return AppMaxWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.homeTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.tasks.isEmpty
                            ? 'Plan your day with a clear task list'
                            : '$pendingCount pending · $completedCount completed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TaskFilterBar(
                    selected: controller.filter.value,
                    onChanged: controller.filterTasks,
                    allCount: controller.tasks.length,
                    pendingCount: pendingCount,
                    completedCount: completedCount,
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
        icon: controller.tasks.isEmpty
            ? Icons.task_alt_outlined
            : controller.filter.value == TaskFilter.completed
            ? Icons.verified_outlined
            : Icons.inbox_outlined,
        actionLabel: controller.tasks.isEmpty ? AppStrings.addTask : null,
        actionIcon: controller.tasks.isEmpty ? Icons.add_rounded : null,
        onAction: controller.tasks.isEmpty
            ? () => Get.toNamed(AppRoutes.addTask)
            : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = items[index];
        return TaskCard(
          task: task,
          onTap: () => Get.toNamed(AppRoutes.taskDetails, arguments: task.id),
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
