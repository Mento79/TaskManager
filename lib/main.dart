import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'providers/task_provider.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';

// Work manager call back dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Flutter binding for background operation
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize Hive in background
    await Hive.initFlutter(); // Ensures Hive is initialized in background
    Hive.registerAdapter(TaskAdapter());
    // Open Hive box in background task
    final taskBox = await Hive.openBox<Task>('taskBox');
    final taskProvider = TaskProvider(taskBox);

    if (task == "checkOverdueTasks") {
      // Perform background overdue task check
      taskProvider.checkAndMarkOverdueTasks();
    } else if (task == "checkTodayTasks") {
      // Perform background upcoming today task check
      taskProvider.checkAndNotifyForTodayTasks();
    }
    return Future.value(true);
  });
}

// Make the background task run in certain time
void scheduleTaskAtTime({
  required String taskId,
  required String taskName,
  required int targetHour,
  required int targetMinute,
}) {
  // Get the current time
  final now = DateTime.now();

  // Calculate the target time for the task
  final targetTime = DateTime(now.year, now.month, now.day, targetHour, targetMinute);

  // If the target time is before the current time, schedule it for tomorrow
  final nextRunTime = targetTime.isBefore(now) ? targetTime.add(Duration(days: 1)) : targetTime;

  // Calculate the initial delay before the task should run
  final initialDelay = nextRunTime.difference(now);

  // Register the periodic task with WorkManager
  Workmanager().registerPeriodicTask(
    taskId, // Unique task ID
    taskName, // Task name
    initialDelay: initialDelay, // Initial delay to run the task at the target time
    frequency: Duration(days: 1), // Run daily
    existingWorkPolicy: ExistingWorkPolicy.replace, // Replace existing task
  );
}

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());

  // Open a Hive box for tasks
  final taskBox = await Hive.openBox<Task>('taskBox');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Local Notifications Plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Check for notifications permission and grant it if not granted
  PermissionStatus status = await Permission.notification.status;
  if (!status.isGranted) {
    // The permission is not granted, request it.
    status = await Permission.notification.request();
  }

  // Inialize the work manager
  Workmanager().initialize(callbackDispatcher);

  // Schedule the overdue check at 12:00 AM every day
  scheduleTaskAtTime(
    taskId: "checkOverdueTasks",
    taskName: "checkOverdueTasks",
    targetHour: 0, // 12:00 AM
    targetMinute: 0,
  );

  // Schedule the upcoming today check at 7:00 AM every day
  scheduleTaskAtTime(
    taskId: "checkTodayTasks",
    taskName: "checkTodayTasks",
    targetHour: 7, // 7:00 AM
    targetMinute: 0,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskBox),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue[400],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
    );
  }
}
