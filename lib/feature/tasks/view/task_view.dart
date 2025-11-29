import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/theme/app_container_styles.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/tasks/mixin/task_view_mixin.dart';
import 'package:farmodo/feature/tasks/view/add_task_view.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/widget/custom_task_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with TaskViewMixin {
  final navigationController = getIt<NavigationController>();
  final authService = getIt<AuthService>();
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildTabBarView(),
        floatingActionButton: _buildFloatingButton(context),
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withAlpha(75),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          if (!authService.isLoggedIn) {
            _showLoginBottomSheet();
          } else {
            RouteHelper.push(context, const AddTaskView());
          }
        },
        backgroundColor: AppColors.danger,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'tasks.custom_task'.tr(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLoginBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      builder: (context) => LoginBottomSheet(
        title: 'tasks.login_to_create_task'.tr(),
        subTitle: 'tasks.login_to_save_tasks'.tr(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      toolbarHeight: context.dynamicHeight(0.08),
      title: _buildTitle(),
      centerTitle: false,
      bottom: _buildTabBar(),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'tasks.my_tasks'.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'tasks.manage_tasks'.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: Size.fromHeight(context.dynamicHeight(0.06)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
        ).copyWith(bottom: context.dynamicHeight(0.015)),
        child: Container(
          height: context.dynamicHeight(0.045),
          decoration: AppContainerStyles.primaryContainer(context),
          padding: EdgeInsets.all(context.dynamicHeight(0.005)),
          child: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            unselectedLabelColor: isDark ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'tasks.active'.tr()),
              Tab(text: 'tasks.completed'.tr()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      children: [
        _buildTaskList(
          listType: taskController.activeUserTasks,
          loadingType: LoadingType.active,
          scrollController: activeScrollController,
        ),
        _buildTaskList(
          listType: taskController.completedUserTasks,
          loadingType: LoadingType.completed,
          scrollController: completedScrollController,
        ),
      ],
    );
  }

  Widget _buildTaskList({
    required RxList<UserTaskModel> listType,
    required LoadingType loadingType,
    required ScrollController scrollController,
  }) {
    return CustomTaskList(
      listType: listType,
      loadingType: loadingType,
      taskController: taskController,
      timerController: timerController,
      scrollController: scrollController,
    );
  }
}

