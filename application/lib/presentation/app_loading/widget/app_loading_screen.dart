// import 'package:flare_loading/flare_loading.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:rive/rive.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FlareActor(
        "assets/animation.flr2d",
        alignment: Alignment.center,
        fit: BoxFit.contain,
        // animation: "idle",
      ),
      // FlareLoading(
      //   name: 'assets/animation.flr2d',
      //   // startAnimation: 'intro',
      //   // loopAnimation: 'circle',
      //   // endAnimation: 'end',
      //   onSuccess: (_) {},
      //   onError: (a, b) {},
      // ),
      // RiveAnimation.asset('assets/animation.flr2d'),
      //  Lottie.asset('assets/logo_animation.json'),
    );
  }
}
