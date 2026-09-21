import 'package:flutter/material.dart';

import '../app/constants/app_strings.dart';
import '../data/models/task_filter.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TaskFilter selected;
  final ValueChanged<TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TaskFilter>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: TaskFilter.all,
          label: Text(AppStrings.filterAll),
        ),
        ButtonSegment(
          value: TaskFilter.pending,
          label: Text(AppStrings.filterPending),
        ),
        ButtonSegment(
          value: TaskFilter.completed,
          label: Text(AppStrings.filterCompleted),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) {
        if (values.isNotEmpty) {
          onChanged(values.first);
        }
      },
    );
  }
}
