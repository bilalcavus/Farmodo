import 'package:farmodo/core/theme/app_colors.dart';
import 'package:farmodo/core/utility/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/models/user_task_model.dart';
import 'package:farmodo/feature/tasks/mixin/task_view_mixin.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/widget/custom_task_list.dart';
import 'package:farmodo/feature/tasks/widget/task_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> with TaskViewMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildTabBarView(),
        floatingActionButton: const TaskFloatingButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: _buildTitle(),
      centerTitle: true,
      bottom: _buildTabBar(),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Tasks',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        height: context.dynamicHeight(0.042),
        margin: EdgeInsets.symmetric(
          horizontal: context.dynamicWidth(0.04),
          vertical: context.dynamicHeight(0.02),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerHeight: 0,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
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

