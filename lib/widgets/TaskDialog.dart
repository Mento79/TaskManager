import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDialog extends StatefulWidget {
  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  int _priority = 1;

  DateTime? _deadline;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            DropdownButtonFormField(
              value: _priority,
              items: [
                DropdownMenuItem(child: Text('High'), value: 0),
                DropdownMenuItem(child: Text('Medium'), value: 1),
                DropdownMenuItem(child: Text('Low'), value: 2),
              ],
              onChanged: (int? newValue) {
                _priority = newValue!;
              },
              decoration: InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
                'Deadline: ${_deadline.toString().split(' ')[0] == 'null' ? '' : _deadline.toString().split(' ')[0]}'),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _deadline = pickedDate;
                    print('bingo');
                  });
                }
              },
              child: Text('Select Deadline'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty && _deadline != null) {
              final newTask = Task(
                title: _titleController.text,
                description: _descriptionController.text,
                priority: _priority,
                deadline: _deadline!,
                isOverdue: DateTime.now()
                    .isAfter(_deadline!.add(Duration(days: 1)).subtract(Duration(milliseconds: 1))),
                isCompleted: false,
              );

              // Access TaskProvider and add the new task
              Provider.of<TaskProvider>(context, listen: false).addTask(newTask);

              Navigator.of(context).pop();
            } else {
              // Handle empty title
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Title cannot be empty!')),
              );
            }
          },
          child: Text('Add Task'),
        ),
      ],
    );
  }
}
