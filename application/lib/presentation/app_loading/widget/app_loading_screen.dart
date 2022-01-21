import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset('assets/logo_animation.json'),
    );
  }
}
