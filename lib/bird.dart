import 'package:flutter/material.dart';
import 'package:flutter_flappy_bird/welcome.dart';
import 'dart:async';

class MyBird extends StatelessWidget {
  final String selectedAvatar;
  const MyBird({super.key, required this.selectedAvatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      child: Image.asset(selectedAvatar), // Choix de l'avatar
    );
  }
}
