import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.fontSize,
    required this.radius
  });

  final User? user;
  final double fontSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      backgroundImage: user?.photoURL != null 
          ? NetworkImage(user!.photoURL!) 
          : null,
      child: user?.photoURL == null 
          ? Text(
              user?.displayName?.isNotEmpty == true 
                  ? user!.displayName![0].toUpperCase()
                  : '👤',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            )
          : null,
    );
  }
} 