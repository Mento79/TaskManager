# Task Manager App

Task Manager App is a Flutter-based application designed to help users organize, manage, and track tasks efficiently. The app features task categorization, notifications for upcoming and overdue tasks, and background checks using `WorkManager`.

## Features

- **Task Creation, Edition and Deletion**: Add tasks with titles, deadlines, and descriptions.Edit or delete them if there are mistakes.
- **Task Status**: Tasks can have different statuses, such as `Completed`, `In Progress`, and `Overdue`.
- **Task Sorting and Filtering**: Tasks can be sorted and filtered by different attributes.
- **Totally Offline app**: The data is stored locally using `Hive`.
- **Pie Chart Overview**: View a pie chart of your tasks to get a quick overview of the status distribution.
- **Automatic Overdue Task Detection**: The app automatically marks tasks as overdue if their deadline has passed.
- **Daily Notifications**:
    - Notify the user if any task is due today (at 7:00 AM).
    - Check and notify the user of overdue tasks (at 12:00 AM).
- **Background Task Handling**: Using `WorkManager`, the app can check for overdue and upcoming tasks even when the app is closed.
- **Local Notifications**: Sends local notifications using `flutter_local_notifications` when tasks are due or overdue.
- **Automatic Building, Releasing and deployment**: The app automatically build apk and make a release on github and deploy it to the workflow on every push or pull request to the main branch.
- **Dark mode**: The app contains dark mode for who hates dark mode as it attracts bugs.

## Downloading The app

You can download it from [Github](https://github.com/Mento79/TaskManager/releases/) or from [Google Drive](https://drive.google.com/file/d/1jeawYBdW5BX0buXXW-pyMOFs3jcA88DK/)

## Getting Started

### Prerequisites

- Android Studio or Xcode for iOS development
- [Flutter](https://flutter.dev/) 3.x or higher
- [Dart](https://dart.dev/) SDK
- [Hive](https://pub.dev/packages/hive) for local database management
- [WorkManager](https://pub.dev/packages/workmanager) for background tasks
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for local notifications
- [permission_handler](https://pub.dev/packages/permission_handler) for managing notification permissions

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/Mento79/TaskManager.git
   cd TaskManager

2. **Install dependencies**:

   ```bash
   flutter pub get


3. **Install dependencies**:

   ```bash
   flutter pub get


