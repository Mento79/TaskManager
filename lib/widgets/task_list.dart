import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/widgets/rounded_expansion_tile.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'edit_task_dialog.dart';

class TaskList extends StatelessWidget {
  final int tabIndex;

  TaskList({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    List<Task> tasks = taskProvider.filtered ? taskProvider.filteredTasks : taskProvider.allTasks;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          color: task.isCompleted
              ? Colors.green[Theme.of(context).brightness == Brightness.dark ? 900 : 500]
              : task.isOverdue
                  ? Colors.red[Theme.of(context).brightness == Brightness.dark ? 900 : 500]
                  : Colors.orange[Theme.of(context).brightness == Brightness.dark ? 900 : 500],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: RoundedExpansionTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                // Update task status in provider
                taskProvider.updateTaskStatus(task, value!);
                taskProvider.applySortingAndFiltering();
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            subtitle: Text('Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Icon(
                  index < (3-task.priority) ? Icons.star : Icons.star_outline,
                  color: Colors.yellow, // Color for stars
                );
              }),
            ),
            rotateTrailing: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(80.0, 16.0, 16.0, 16.0),
                child: Text(
                  'Description: ${task.description}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => _openEditTaskDialog(context, task),
                    child: Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => taskProvider.deleteTask(task),
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  // Helper method to convert priority to a readable label
  String _priorityToString(int priority) {
    switch (priority) {
      case 0:
        return 'High';
      case 1:
        return 'Medium';
      case 2:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  void _openEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTaskDialog(task: task); // Open EditTaskDialog
      },
    );
  }
}

