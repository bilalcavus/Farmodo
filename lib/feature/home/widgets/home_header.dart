
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/utility/extension/ontap_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/feature/home/widgets/leader_board_button.dart';
import 'package:farmodo/feature/leader_board/view/leader_board_view.dart';
import 'package:farmodo/feature/home/widgets/user_xp.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';


class HomeHeader extends StatefulWidget {
  const HomeHeader({
    super.key,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    return 
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserXp(authService: authService),
          LeaderBoardButton().onTap(() => Get.to(() => const LeaderBoardView())),
        ],
      );
    }
  }

