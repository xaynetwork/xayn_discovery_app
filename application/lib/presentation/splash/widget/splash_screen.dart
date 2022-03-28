import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/splash/manager/splash_screen_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final _splashScreenManager = di.get<SplashScreenManager>();
  late LottieBuilder _lottieBuilder;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_animationStatusListener);
    _prepareLottie();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: _lottieBuilder),
      );

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _splashScreenManager.onSplashScreenAnimationFinished();
    }
  }

  void _prepareLottie() {
    _lottieBuilder = Lottie.asset(
      R.assets.lottie.splashScreenJson(R.brightness),
      controller: _controller,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward();
      },
    );
  }
}
