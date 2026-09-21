# Task Manager

A clean Flutter Task Manager app for creating, viewing, updating, completing, and deleting tasks. Tasks are stored locally with GetStorage, so they remain available after the app is restarted.

This project is intentionally small and easy to explain in a Flutter interview: GetX for state, a simple feature-based folder structure, and Material 3 UI.

## Features

- View all tasks with title, description, priority, due date, and status
- Filter tasks: All, Pending, Completed
- Add a task with title, description, priority, and due date
- Edit an existing task
- Mark a task as completed or pending
- Open a task details screen
- Delete a task with a confirmation dialog
- Persist tasks locally with GetStorage
- Empty, loading, and error states
- Form validation on add/edit

## Tech stack

- Flutter
- Dart
- GetX for state management and navigation
- GetStorage for local storage
- Material 3
- intl for date formatting

## Architecture

The UI never talks to storage directly.

```text
User
 ↓
Flutter UI (Views + Widgets)
 ↓
GetX Controller (TaskController)
 ↓
TaskStorage
 ↓
GetStorage
```

- **Model:** `TaskModel` holds task data and JSON mapping
- **Storage:** `TaskStorage` reads and writes the task list
- **Controller:** `TaskController` owns business logic and reactive state
- **View:** screens render state and call controller methods

See [docs/architecture.md](docs/architecture.md) for a longer walkthrough.

## Folder structure

```text
lib/
├── main.dart
├── app/
│   ├── routes/
│   ├── theme/
│   └── constants/
├── data/
│   ├── models/
│   └── storage/
├── controllers/
├── views/
│   ├── home/
│   ├── add_task/
│   └── task_details/
└── widgets/
```

## Screenshots

Add screenshots after you run the app, then drop the files into `docs/screenshots/`.

| Home | Add Task | Task Details |
|------|----------|--------------|
| ![Home](docs/screenshots/home.png) | ![Add Task](docs/screenshots/add-task.png) | ![Task Details](docs/screenshots/task-details.png) |

## How to run the project

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Clone this repository
3. Open the project folder
4. Get packages and run:

```bash
flutter pub get
flutter run
```

You can also run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

## Dependencies

| Package | Why it is used |
|---------|----------------|
| `get` | State management, routing, snackbars |
| `get_storage` | Local persistence on device |
| `intl` | Readable due dates |
| `cupertino_icons` | Extra icons if needed |

Dev:

| Package | Why it is used |
|---------|----------------|
| `flutter_lints` | Lint rules |
| `flutter_test` | Tests |

## Future improvements

These are intentionally left out to keep the project simple:

- Search and sort options
- Reminders or notifications
- Cloud backup / sync
- User accounts
- Recurring tasks
- Attachments

## License

This project is intended as a public portfolio sample. Use and adapt it as you like.
