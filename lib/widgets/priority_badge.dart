import 'package:flutter/material.dart';

import '../data/models/task_priority.dart';

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(Theme.of(context).colorScheme, priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _colorsFor(
    ColorScheme scheme,
    TaskPriority value,
  ) {
    switch (value) {
      case TaskPriority.high:
        return (
          background: scheme.errorContainer,
          foreground: scheme.onErrorContainer,
        );
      case TaskPriority.medium:
        return (
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        );
      case TaskPriority.low:
        return (
          background: scheme.secondaryContainer,
          foreground: scheme.onSecondaryContainer,
        );
    }
  }
}
