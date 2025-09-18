import 'package:farmodo/core/components/custom_bottom_bar.dart';
import 'package:farmodo/feature/account/account_view.dart';
import 'package:farmodo/feature/farm/view/farm_game_view.dart';
import 'package:farmodo/feature/home/view/home_view.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/tasks/view/task_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppNavigation extends StatelessWidget {
  AppNavigation({super.key});

  final NavigationController navController = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Arka plan rengi
        statusBarIconBrightness: Brightness.dark, // Android ikonları
        statusBarBrightness: Brightness.light, // iOS ikonları
      ),
      child: Obx(() {
        return Scaffold(
          body: IndexedStack(
            index: navController.currentIndex.value,
            children:  [
              HomeView(),
              TaskView(),
              FarmGameView(),
              AccountView()
            ],
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changePage,
          ),
        );
      }),
    );
  }
}