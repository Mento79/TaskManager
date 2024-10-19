import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;

  EditTaskDialog({required this.task});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDeadline;
  late int _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDeadline = widget.task.deadline;
    _selectedPriority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return AlertDialog(
      title: Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16),

            // Task Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),

            // Priority Dropdown
            DropdownButtonFormField<int>(
              value: _selectedPriority,
              decoration: InputDecoration(labelText: 'Priority'),
              items: [
                DropdownMenuItem(value: 0, child: Text('High')),
                DropdownMenuItem(value: 1, child: Text('Medium')),
                DropdownMenuItem(value: 2, child: Text('Low')),
              ],
              onChanged: (int? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            // Deadline Picker
            Text('Deadline: ${_selectedDeadline.toString().split(' ')[0]}'),
            ElevatedButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDeadline,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != _selectedDeadline) {
                  setState(() {
                    _selectedDeadline = picked;
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
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _editTask(taskProvider);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  // Method to update the task
  void _editTask(TaskProvider taskProvider) {
    final updatedTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      deadline: _selectedDeadline,
      priority: _selectedPriority,
      isOverdue: DateTime.now()
          .isAfter(_selectedDeadline!.add(Duration(days: 1)).subtract(Duration(milliseconds: 1))),
      isCompleted: widget.task.isCompleted,
    );

    taskProvider.updateTask(widget.task, updatedTask);
  }
}
