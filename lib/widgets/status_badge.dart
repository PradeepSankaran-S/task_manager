import 'package:flutter/material.dart';

import '../app/constants/app_strings.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isCompleted
        ? (isDark ? const Color(0xFF163428) : const Color(0xFFD1FAE5))
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E7FF));
    final foreground = isCompleted
        ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
        : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule_rounded,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? AppStrings.completed : AppStrings.pending,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
