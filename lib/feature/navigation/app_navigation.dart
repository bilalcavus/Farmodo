import 'package:farmodo/core/components/custom_bottom_bar.dart';
import 'package:farmodo/feature/account/account_view.dart';
import 'package:farmodo/feature/home/view/home_view.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/store/store_view.dart';
import 'package:farmodo/feature/tasks/view/task_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNavigation extends StatelessWidget {
  AppNavigation({super.key});

  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        child: Scaffold(
          body: IndexedStack(
            index: navController.currentIndex.value,
            children:  [
              HomeView(),
              TaskView(),
              StoreView(),
              AccountView()
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changePage,
          ),
        ),
      );
    });
  }
}