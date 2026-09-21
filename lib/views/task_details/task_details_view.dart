import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/constants/app_strings.dart';
import '../../app/constants/date_formatter.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/task_controller.dart';
import '../../widgets/app_max_width.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/priority_badge.dart';

class TaskDetailsView extends GetView<TaskController> {
  const TaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskId = Get.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskDetailsTitle),
        actions: [
          Obx(() {
            final task = taskId == null ? null : controller.findTask(taskId);
            if (task == null) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Get.toNamed(AppRoutes.addTask, arguments: task);
                } else if (value == 'delete') {
                  await _delete(context, task.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text(AppStrings.edit)),
                PopupMenuItem(value: 'delete', child: Text(AppStrings.delete)),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final task = taskId == null ? null : controller.findTask(taskId);
          if (task == null) {
            return const EmptyState(
              title: AppStrings.notFound,
              message: 'Go back to the home screen and select another task.',
            );
          }

          final theme = Theme.of(context);

          return AppMaxWidth(
            child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                task.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityBadge(priority: task.priority),
                  Chip(
                    avatar: Icon(
                      task.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.schedule_outlined,
                      size: 18,
                    ),
                    label: Text(
                      task.isCompleted
                          ? AppStrings.completed
                          : AppStrings.pending,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailTile(
                icon: Icons.notes_outlined,
                label: AppStrings.descriptionLabel,
                value: task.description.isEmpty
                    ? 'No description added'
                    : task.description,
              ),
              const SizedBox(height: 12),
              _DetailTile(
                icon: Icons.event_outlined,
                label: AppStrings.dueDateLabel,
                value: DateFormatter.display(task.dueDate),
              ),
              const SizedBox(height: 12),
              _DetailTile(
                icon: Icons.calendar_today_outlined,
                label: 'Created',
                value: DateFormatter.display(task.createdAt),
              ),
              const SizedBox(height: 28),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mark as completed'),
                subtitle: Text(
                  task.isCompleted
                      ? 'This task is marked complete'
                      : 'This task is still pending',
                ),
                value: task.isCompleted,
                onChanged: (_) => controller.toggleTaskStatus(task.id),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    Get.toNamed(AppRoutes.addTask, arguments: task),
                icon: const Icon(Icons.edit_outlined),
                label: const Text(AppStrings.edit),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _delete(context, task.id),
                icon: const Icon(Icons.delete_outline),
                label: const Text(AppStrings.delete),
              ),
            ],
          ),
          );
        }),
      ),
    );
  }

  Future<void> _delete(BuildContext context, String taskId) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage,
    );
    if (!confirmed) return;

    final success = await controller.deleteTask(taskId);
    if (success) {
      Get.back();
    }
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
