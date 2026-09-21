import 'package:get/get.dart';

import '../../views/add_task/add_task_view.dart';
import '../../views/home/home_view.dart';
import '../../views/task_details/task_details_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(name: AppRoutes.home, page: () => const HomeView()),
    GetPage(name: AppRoutes.addTask, page: () => const AddTaskView()),
    GetPage(
      name: AppRoutes.taskDetails,
      page: () => const TaskDetailsView(),
    ),
  ];
}
