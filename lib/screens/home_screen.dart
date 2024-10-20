import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/TaskDialog.dart';
import '../widgets/TaskPieChart.dart';
import '../widgets/task_list.dart';
import '../providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<String> _tabs = ['All Tasks', 'In Progress', 'Completed', 'Overdue'];

  void _openTaskDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDialog(); // Open TaskDialog
      },
    );
  }

  // Generate pie chart sections based on task status counts

  List<PieChartSectionData> _generatePieChartSections(int completed, int inProgress, int overdue) {
    final total = completed + inProgress + overdue;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: (completed / total) * 100,
        title: '${(completed / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: (inProgress / total) * 100,
        title: '${(inProgress / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: (overdue / total) * 100,
        title: '${(overdue / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  void _showPieChartDialog(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final completedCount = taskProvider.completedTasks.length;
    final inProgressCount = taskProvider.inProgressTasks.length;
    final overdueCount = taskProvider.overdueTasks.length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Task Status Overview'),
          content: Container(
            height: 300,
            width: 300,
            child: TaskPieChart(
              completedTasks: completedCount,
              inProgressTasks: inProgressCount,
              overdueTasks: overdueCount,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          // Pie chart button in the AppBar
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () => _showPieChartDialog(context),
          ),
          // Sort button
          PopupMenuButton<String>(
            onSelected: (value) {
              taskProvider.selectSort(value);
            },
            icon: Icon(Icons.sort),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Priority',
                  child: Text('Sort by Priority'),
                ),
                PopupMenuItem(
                  value: 'Deadline',
                  child: Text('Sort by Deadline'),
                ),
              ];
            },
          ),
          // Filter button
          PopupMenuButton<String>(
            onSelected: (value) {
              taskProvider.selectFilter(value, true);
            },
            icon: Icon(Icons.filter_list),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'Completed',
                  child: Text('Filter by Completed'),
                ),
                PopupMenuItem(
                  value: 'In Progress',
                  child: Text('Filter by In Progress'),
                ),
                PopupMenuItem(
                  value: 'Overdue',
                  child: Text('Filter by Overdue'),
                ),
                PopupMenuItem(
                  value: 'High Priority',
                  child: Text('Filter by High Priority'),
                ),
                PopupMenuItem(
                  value: 'Medium Priority',
                  child: Text('Filter by Medium Priority'),
                ),
                PopupMenuItem(
                  value: 'Low Priority',
                  child: Text('Filter by Low Priority'),
                ),
                PopupMenuItem(
                  value: 'Deadline is upcoming',
                  child: Text('Filter by Deadline is upcoming'),
                ),
                PopupMenuItem(
                  value: 'Deadline is today',
                  child: Text('Filter by Deadline today'),
                ),
                PopupMenuItem(
                  value: 'Deadline is in a week',
                  child: Text('Filter by Deadline this week'),
                ),
              ];
            },
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: TaskList(tabIndex: _selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          taskProvider.selectFilter(_tabs[index], false);
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'In Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Completed'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Overdue'),
        ],
        fixedColor: Theme.of(context).primaryColor,
        unselectedItemColor:
            Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
