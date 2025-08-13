import 'package:farmodo/core/extension/dynamic_size_extension.dart';
import 'package:farmodo/core/extension/route_helper.dart';
import 'package:farmodo/view/navigation/app_navigation.dart';
import 'package:flutter/material.dart';

class SucceedTaskPage extends StatelessWidget {
  const SucceedTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.dynamicHeight(0.08)),
          child: Column(
            children: [
              Image.asset('assets/images/medal.png', height: context.dynamicHeight(0.4),),
              Text('Congratulations!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold
              )),
              Text('Task is completed.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500
              )),
              SizedBox(height: context.dynamicHeight(0.1)),
              InkWell(
                onTap: () {
                  RouteHelper.pushAndCloseOther(context, AppNavigation());
                },
                child: Container(
                  alignment: Alignment.center,
                  width: context.dynamicWidth(0.7),
                  height: context.dynamicHeight(0.07),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(context.dynamicHeight(.02))
                  ),
                  child: Text('Back to Home', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white
                  ),),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}