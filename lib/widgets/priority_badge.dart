import 'package:flutter/material.dart';

import '../data/models/task_priority.dart';

class PriorityStyle {
  const PriorityStyle({
    required this.background,
    required this.foreground,
    required this.accent,
  });

  final Color background;
  final Color foreground;
  final Color accent;

  static PriorityStyle of(BuildContext context, TaskPriority priority) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (priority) {
      case TaskPriority.high:
        return PriorityStyle(
          background: isDark
              ? const Color(0xFF3F1D1D)
              : const Color(0xFFFEE2E2),
          foreground: isDark
              ? const Color(0xFFFCA5A5)
              : const Color(0xFFB91C1C),
          accent: const Color(0xFFDC2626),
        );
      case TaskPriority.medium:
        return PriorityStyle(
          background: isDark
              ? const Color(0xFF3F2E14)
              : const Color(0xFFFEF3C7),
          foreground: isDark
              ? const Color(0xFFFCD34D)
              : const Color(0xFFB45309),
          accent: const Color(0xFFD97706),
        );
      case TaskPriority.low:
        return PriorityStyle(
          background: isDark
              ? const Color(0xFF163428)
              : const Color(0xFFD1FAE5),
          foreground: isDark
              ? const Color(0xFF6EE7B7)
              : const Color(0xFF047857),
          accent: const Color(0xFF059669),
        );
    }
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final colors = PriorityStyle.of(context, priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
