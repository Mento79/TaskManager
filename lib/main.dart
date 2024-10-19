import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'providers/task_provider.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';


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
      print(taskProvider.allTasks.length);
    } else if (task == "checkTodayTasks") {
      // Perform background upcoming today task check
      taskProvider.checkAndNotifyForTodayTasks();
    }
    return Future.value(true);
  });
}

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
  final nextRunTime = targetTime.isBefore(now)
      ? targetTime.add(Duration(days: 1))
      : targetTime;

  // Calculate the initial delay before the task should run
  final initialDelay = nextRunTime.difference(now);

  // Register the periodic task with WorkManager
  Workmanager().registerPeriodicTask(
    taskId,           // Unique task ID
    taskName,         // Task name
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  PermissionStatus status = await Permission.notification.status;

  if (!status.isGranted) {
// The permission is not granted, request it.
    status = await Permission.notification.request();
  }

  Workmanager().initialize(callbackDispatcher);

  // Schedule the overdue check at 12:00 AM every day
  scheduleTaskAtTime(
    taskId: "checkOverdueTasks",
    taskName: "checkOverdueTasks",
    targetHour: 12, // 12:00 AM
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
          primarySwatch: Colors.blue
      ),
      home: HomeScreen(),
    );
  }
}
