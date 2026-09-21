# Architecture

This app is a local Task Manager. It uses a simple Model–Controller–View flow with GetX. There is no repository layer, no API, and no backend.

## High-level flow

```text
User
 ↓
Flutter UI
 ↓
GetX Controller
 ↓
Local Storage
 ↓
GetStorage
```

1. The user taps an action in a screen (add, edit, complete, delete, filter).
2. The screen calls a method on `TaskController`.
3. The controller updates the in-memory task list and writes it through `TaskStorage`.
4. `TaskStorage` saves a JSON list in `GetStorage`.
5. Reactive variables (`Rx`) rebuild the UI.

## Layers

### Views

Screens live in `lib/views/`:

- `HomeView` lists tasks and applies the current filter
- `AddTaskView` is used for both create and edit
- `TaskDetailsView` shows one task and actions for that task

Views should not save to GetStorage themselves. They only:

- read state from the controller
- call controller methods
- handle navigation and form input

### Widgets

Reusable UI pieces live in `lib/widgets/`:

- `TaskCard`
- `TaskFilterBar`
- `PriorityBadge`
- `EmptyState`
- `showConfirmDialog`
- `AppMaxWidth`

### Controller

`TaskController` is the single source of truth for tasks. It exposes:

- `addTask()`
- `updateTask()`
- `deleteTask()`
- `toggleTaskStatus()`
- `getTasks()`
- `filterTasks()`

Reactive state:

- `tasks` — full list
- `filter` — All / Pending / Completed
- `isLoading`
- `errorMessage`

`filteredTasks` is a getter. It does not store a second list.

### Model

`TaskModel` fields:

- `id`
- `title`
- `description`
- `priority`
- `dueDate`
- `isCompleted`
- `createdAt`

JSON is mapped by hand with `toJson()` and `fromJson()`.

### Storage

`TaskStorage` is a thin wrapper around GetStorage:

- `loadTasks()` reads the saved list
- `saveTasks()` writes the full list

The storage key is `tasks` (`AppConstants.tasksStorageKey`).

## Navigation

GetX named routes are defined in `lib/app/routes/`:

- `/` home
- `/add-task` add or edit
- `/task-details` details

Edit mode is selected by passing a `TaskModel` as the route argument. Details receives a task `id` so the screen always reads the latest value from the controller.

## Persistence

On startup, `main.dart` initializes GetStorage, puts `TaskController`, and the controller loads tasks in `onInit()`.

Every successful add, update, delete, or status change writes the full list again. That keeps the storage format easy to reason about for a small app.

## Why this structure

For a local CRUD app, this is enough:

- Easy to explain in an interview
- UI and business logic stay separate
- No extra service/repository files that only forward method calls
