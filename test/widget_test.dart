import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/models/task_priority.dart';

void main() {
  test('TaskModel keeps data through JSON serialization', () {
    final createdAt = DateTime(2026, 1, 10, 9);
    final dueDate = DateTime(2026, 1, 15);

    final original = TaskModel(
      id: '1',
      title: 'Prepare interview notes',
      description: 'Review GetX and GetStorage',
      priority: TaskPriority.high,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: createdAt,
    );

    final restored = TaskModel.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.description, original.description);
    expect(restored.priority, original.priority);
    expect(restored.dueDate, original.dueDate);
    expect(restored.isCompleted, original.isCompleted);
    expect(restored.createdAt, original.createdAt);
  });
}
