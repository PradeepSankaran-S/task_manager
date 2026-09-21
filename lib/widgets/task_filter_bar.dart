import 'package:flutter/material.dart';

import '../app/constants/app_strings.dart';
import '../data/models/task_filter.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.allCount,
    required this.pendingCount,
    required this.completedCount,
  });

  final TaskFilter selected;
  final ValueChanged<TaskFilter> onChanged;
  final int allCount;
  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: AppStrings.filterAll,
          count: allCount,
          selected: selected == TaskFilter.all,
          onTap: () => onChanged(TaskFilter.all),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: AppStrings.filterPending,
          count: pendingCount,
          selected: selected == TaskFilter.pending,
          onTap: () => onChanged(TaskFilter.pending),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: AppStrings.filterCompleted,
          count: completedCount,
          selected: selected == TaskFilter.completed,
          onTap: () => onChanged(TaskFilter.completed),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final foreground = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? null
                  : Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
            ),
            child: Text(
              '$label $count',
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
