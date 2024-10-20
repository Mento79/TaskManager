import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Widget to display task statistics in a pie chart format
class TaskPieChart extends StatelessWidget {
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;

  TaskPieChart({
    required this.completedTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        startDegreeOffset: 0, // Ensures the pie chart is a full circle
        sectionsSpace: 0, // No space between sections for a complete look
        centerSpaceRadius: 0, // Adjust this to make the chart more compact
        sections: _buildPieChartSections(),
      ),
    );
  }

  // Function to generate pie chart sections based on task counts
  List<PieChartSectionData> _buildPieChartSections() {
    final totalTasks = completedTasks + inProgressTasks + overdueTasks;
    final completedPercentage = (completedTasks / totalTasks) * 100;
    final inProgressPercentage = (inProgressTasks / totalTasks) * 100;
    final overduePercentage = (overdueTasks / totalTasks) * 100;

    return [
      if (completedPercentage != 0)
        PieChartSectionData(
          color: Colors.green,
          value: completedPercentage,
          title: 'Completed\n${completedPercentage.toStringAsFixed(1)}%',
          radius: 120,
          // Radius to make the section size visible
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          showTitle: true, // Ensure labels are visible
        ),
      if (inProgressPercentage != 0)
        PieChartSectionData(
          color: Colors.orange,
          value: inProgressPercentage,
          title: 'In Progress\n${inProgressPercentage.toStringAsFixed(1)}%',
          radius: 120,
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          showTitle: true,
        ),
      if (overduePercentage != 0)
        PieChartSectionData(
          color: Colors.red,
          value: overduePercentage,
          title: 'Overdue\n${overduePercentage.toStringAsFixed(1)}%',
          radius: 120,
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          showTitle: true,
        ),
    ];
  }
}
