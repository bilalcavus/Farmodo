import 'package:farmodo/view/account/account_view.dart';
import 'package:farmodo/view/home/home_view.dart';
import 'package:farmodo/view/store/store_view.dart';
import 'package:farmodo/view/tasks/task_view.dart';
import 'package:farmodo/view/widget/custom_bottom_bar.dart';
import 'package:farmodo/viewmodel/navigation_controller.dart';
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