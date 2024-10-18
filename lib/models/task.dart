import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int priority; // 0: High, 1: Medium, 2: Low

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  bool isOverdue;

  Task({
    required this.title,
    required this.description,
    required this.priority,
    required this.deadline,
    this.isCompleted = false,
    required this.isOverdue,
  });
}
