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
import '../../widgets/status_badge.dart';

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
              icon: Icons.search_off_rounded,
            );
          }

          final theme = Theme.of(context);
          final isOverdue =
              !task.isCompleted &&
              task.dueDate.isBefore(
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              );

          return AppMaxWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PriorityBadge(priority: task.priority),
                    StatusBadge(isCompleted: task.isCompleted),
                  ],
                ),
                const SizedBox(height: 20),
                _InfoCard(
                  icon: Icons.notes_rounded,
                  label: AppStrings.descriptionLabel,
                  value: task.description.isEmpty
                      ? 'No description added'
                      : task.description,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.event_rounded,
                  label: AppStrings.dueDateLabel,
                  value: isOverdue
                      ? 'Overdue · ${DateFormatter.display(task.dueDate)}'
                      : DateFormatter.display(task.dueDate),
                  valueColor: isOverdue ? theme.colorScheme.error : null,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created',
                  value: DateFormatter.display(task.createdAt),
                ),
                const SizedBox(height: 20),
                _CompletionCard(
                  isCompleted: task.isCompleted,
                  onChanged: () => controller.toggleTaskStatus(task.id),
                ),
                const SizedBox(height: 20),
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

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.isCompleted,
    required this.onChanged,
  });

  final bool isCompleted;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = isCompleted
        ? (isDark ? const Color(0xFF163428) : const Color(0xFFECFDF5))
        : theme.colorScheme.surface;
    final border = isCompleted
        ? const Color(0xFF86EFAC).withValues(alpha: 0.7)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.7);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onChanged,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(
              isCompleted ? 'Task completed' : 'Mark as completed',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              isCompleted
                  ? 'Turn this off to move it back to pending'
                  : 'This task is still pending',
            ),
            value: isCompleted,
            onChanged: (_) => onChanged(),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
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
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
