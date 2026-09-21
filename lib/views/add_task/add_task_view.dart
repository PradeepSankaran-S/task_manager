import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/app_strings.dart';
import '../../app/constants/date_formatter.dart';
import '../../controllers/task_controller.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_priority.dart';
import '../../widgets/app_max_width.dart';
import '../../widgets/priority_badge.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _controller = Get.find<TaskController>();

  late final TaskModel? _existingTask;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isSaving = false;

  bool get _isEditing => _existingTask != null;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final existing = args is TaskModel ? args : null;
    _existingTask = existing;

    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _priority = existing.priority;
      _dueDate = existing.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editTaskTitle : AppStrings.addTaskTitle,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: AppMaxWidth(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      Text(
                        _isEditing
                            ? 'Update the details below'
                            : 'Add the details below',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: AppConstants.titleMaxLength,
                        decoration: const InputDecoration(
                          labelText: AppStrings.titleLabel,
                          hintText: AppStrings.titleHint,
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        validator: _validateTitle,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        maxLength: AppConstants.descriptionMaxLength,
                        decoration: const InputDecoration(
                          labelText: AppStrings.descriptionLabel,
                          hintText: AppStrings.descriptionHint,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.priorityLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          for (final priority in TaskPriority.values) ...[
                            if (priority != TaskPriority.low)
                              const SizedBox(width: 8),
                            Expanded(
                              child: _PriorityOption(
                                priority: priority,
                                selected: _priority == priority,
                                onTap: () =>
                                    setState(() => _priority = priority),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.event_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.dueDateLabel,
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _dueDate == null
                                            ? 'Tap to choose a date'
                                            : DateFormatter.display(_dueDate!),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: _dueDate == null
                                              ? theme.colorScheme.error
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isEditing
                                ? AppStrings.updateTask
                                : AppStrings.saveTask,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return AppStrings.titleRequired;
    if (title.length < AppConstants.titleMinLength) {
      return AppStrings.titleTooShort;
    }
    return null;
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now;
    final firstDate = DateTime(now.year - 1);
    final lastDate = DateTime(now.year + 5);

    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? now : initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dueDate == null) {
      Get.snackbar(
        AppConstants.appName,
        AppStrings.dueDateRequired,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = _isEditing
        ? await _controller.updateTask(
            _existingTask!.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              priority: _priority,
              dueDate: _dueDate!,
            ),
          )
        : await _controller.addTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _priority,
            dueDate: _dueDate!,
          );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Get.back();
    }
  }
}

class _PriorityOption extends StatelessWidget {
  const _PriorityOption({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final TaskPriority priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = PriorityStyle.of(context, priority);

    return Material(
      color: selected ? colors.background : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? colors.accent
                  : Theme.of(context).colorScheme.outlineVariant.withValues(
                      alpha: 0.7,
                    ),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Center(
            child: Text(
              priority.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? colors.foreground
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
