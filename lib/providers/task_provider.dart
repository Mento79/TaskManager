import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  Box<Task> _taskBox;
  List<Task> _filteredTasks =[];
  String _sortOption='';
  String _filterOption='';
  bool ascending = true;
  bool filtered = false;

  // Constructor to initialize the task provider with a Hive box
  TaskProvider(this._taskBox);

  // Get all tasks
  List<Task> get allTasks => _taskBox.values.toList();

  // Get filtered tasks
  List<Task> get filteredTasks => _filteredTasks;

  // Getter to retrieve completed tasks
  List<Task> get completedTasks => _taskBox.values.where((task) => task.isCompleted).toList();

  // Getter to retrieve in-progress tasks
  List<Task> get inProgressTasks => _taskBox.values.where((task) => !task.isCompleted && !task.isOverdue).toList();

  // Getter to retrieve overdue tasks
  List<Task> get overdueTasks => _taskBox.values.where((task) => !task.isCompleted && task.isOverdue).toList();

  // Add a new task
  void addTask(Task task) {
    _taskBox.add(task);
    notifyListeners(); // Notify listeners that the task list has changed
  }

// Update the completion status of a task
  void updateTaskStatus(Task task, bool isCompleted) {
    final index = _taskBox.values.toList().indexOf(task);
    task.isCompleted = isCompleted;
    _taskBox.putAt(index, task); // Update the task in Hive box
    notifyListeners(); // Notify listeners that the task has been updated
  }

  // Delete a task
  void deleteTask(Task task) {
    final index = _taskBox.values.toList().indexOf(task);
    _taskBox.deleteAt(index);
    notifyListeners();
  }
  
  void selectFilter(String filterOption, bool clear){

    _filterOption = _filterOption ==filterOption && clear ?'' : filterOption;
    filtered = clear?!filtered:true;
    _sortOption ='';
    ascending = true;
    applySortingAndFiltering();
  }
  
  void selectSort(String sortOption){
    if(_sortOption == sortOption){
      ascending = !ascending;
    }
    else{
      ascending = true;
    }
    _sortOption = sortOption;
    applySortingAndFiltering();
  }
  
  void filterByCompletionStatus(bool isCompleted) {
    final filteredTasks = _taskBox.values
        .where((task) => isCompleted
                                    ? task.isCompleted == isCompleted
                                    : task.isCompleted == isCompleted && !task.isOverdue)
        .toList();
    // Replace the task list with the filtered tasks
    _filteredTasks = filteredTasks;
    notifyListeners();
  }

  void filterByOverdue() {
    final filteredTasks = _taskBox.values
        .where((task) => !task.isCompleted && task.isOverdue)
        .toList();
    // Replace the task list with the filtered tasks
    _filteredTasks = filteredTasks;
    notifyListeners();
  }

  void filterByPriority(int priority) {
    final filteredTasks = _taskBox.values
        .where((task) => task.priority == priority)
        .toList();
    // Replace the task list with the filtered tasks
    _filteredTasks = filteredTasks;
    notifyListeners();
  }

  // Filter tasks by upcoming deadlines
  void filterByUpcomingDeadline() {
    final filteredTasks = _taskBox.values
        .where((task) => task.deadline.isAfter(DateTime.now()))
        .toList();
    _filteredTasks = filteredTasks;
    notifyListeners();
  }

  // Filter tasks due today
  void filterByTodayDeadline() {
    final today = DateTime.now();
    final filteredTasks = _taskBox.values.where((task) {
      return task.deadline.year == today.year &&
          task.deadline.month == today.month &&
          task.deadline.day == today.day;
    }).toList();
    _filteredTasks = filteredTasks;
    notifyListeners();
  }

  // Filter tasks due within the next week
  void filterByWeekDeadline() {
    final today = DateTime.now();
    final oneWeekLater = today.add(Duration(days: 7));
    final filteredTasks = _taskBox.values.where((task) {
      return task.deadline.isAfter(today) && task.deadline.isBefore(oneWeekLater);
    }).toList();
    _filteredTasks = filteredTasks;
    notifyListeners();
  }

  // Filter tasks due within the next week
  void clearFilters() {
    _filteredTasks = [];
    filtered = false;
    notifyListeners();
  }

  void sortByPriority(bool ascending) {
    if(_filteredTasks.isEmpty) {
      _filteredTasks = _taskBox.values.toList();
    }
    _filteredTasks.sort(
        (a, b) => ascending
            ? a.priority.compareTo(b.priority)
            : b.priority.compareTo(a.priority));
    notifyListeners();
  }

  void sortByDeadline(bool ascending ) {
    if(_filteredTasks.isEmpty) {
      _filteredTasks = _taskBox.values.toList();
    }
    _filteredTasks.sort((a, b) => ascending
        ? a.deadline.compareTo(b.deadline)
        : b.deadline.compareTo(a.deadline));
    notifyListeners();
  }

  void applySortingAndFiltering(){
    switch(_filterOption){
      case 'Completed':
        filterByCompletionStatus(true);
        break;
      case 'In Progress':
        filterByCompletionStatus(false);
        break;
      case 'Overdue':
        filterByOverdue();
        break;
      case 'High Priority':
        filterByPriority(0);
        break;
      case 'Medium Priority':
        filterByPriority(1);
        break;
      case 'Low Priority':
        filterByPriority(2);
        break;
      case 'Deadline is upcoming':
        filterByUpcomingDeadline();
        break;
      case 'Deadline is today':
        filterByTodayDeadline();
        break;
      case 'Deadline is in a week':
        filterByWeekDeadline();
        break;
      default:
        clearFilters();
        break;
    }
    switch(_sortOption) {
      case 'Priority':
        sortByPriority(ascending);
        break;
      case 'Deadline':
        sortByDeadline(ascending);
        break;
    }
  }

  // Update a task
  void updateTask(Task oldTask, Task newTask) {
    final index = _taskBox.values.toList().indexOf(oldTask);
    _taskBox.putAt(index, newTask);
    notifyListeners();
  }


  // Dispose method to close the Hive box when done
  @override
  void dispose() {
    _taskBox.close();
    super.dispose();
  }
}
