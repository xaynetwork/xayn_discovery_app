import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/app_loading/manager/app_loading_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({Key? key}) : super(key: key);

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final _appLoadingScreenManager = di.get<AppLoadingScreenManager>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_animationStatusListener);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: _buildBody());

  Widget _buildBody() => Center(
        child: Lottie.asset(
          R.assets.lottie.splashScreenJson(R.brightness),
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      );

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _appLoadingScreenManager.onSplashScreenAnimationFinished();
    }
  }
}
