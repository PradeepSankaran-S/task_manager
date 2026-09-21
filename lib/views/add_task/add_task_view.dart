import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/app_strings.dart';
import '../../app/constants/date_formatter.dart';
import '../../controllers/task_controller.dart';
import '../../widgets/app_max_width.dart';
import '../../data/models/task_model.dart';
import '../../data/models/task_priority.dart';

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
            child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: AppConstants.titleMaxLength,
                decoration: const InputDecoration(
                  labelText: AppStrings.titleLabel,
                  hintText: AppStrings.titleHint,
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
              const SizedBox(height: 16),
              Text(
                AppStrings.priorityLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                showSelectedIcon: false,
                segments: [
                  for (final priority in TaskPriority.values)
                    ButtonSegment(
                      value: priority,
                      label: Text(priority.label),
                    ),
                ],
                selected: {_priority},
                onSelectionChanged: (values) {
                  if (values.isNotEmpty) {
                    setState(() => _priority = values.first);
                  }
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                leading: const Icon(Icons.event_outlined),
                title: const Text(AppStrings.dueDateLabel),
                subtitle: Text(
                  _dueDate == null
                      ? AppStrings.dueDateRequired
                      : DateFormatter.display(_dueDate!),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDueDate,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing
                            ? AppStrings.updateTask
                            : AppStrings.saveTask,
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
