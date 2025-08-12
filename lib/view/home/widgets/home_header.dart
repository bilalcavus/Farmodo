
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dynamicWidth(0.05),
        vertical: context.dynamicHeight(0.02)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Hello, ${authService.currentUser?.displayName}!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400
          )),
          Container(
            height: context.dynamicHeight(0.04),
            width: context.dynamicWidth(0.25),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xff81BAE9),
                Color(0xff909090)
              ]),
              borderRadius: BorderRadius.circular(context.dynamicHeight(0.02))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/xp_star.png', height: context.dynamicHeight(0.07),),
                Text('${authService.currentUser!.xp} XP' , style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white
                  ))
              ],
            ),
          )
        ],
      ),
    );
  }
}