import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/splash/manager/splash_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

class SplashScreen extends StatelessWidget {
  late final _splashScreenManager = di.get<SplashScreenManager>();
  late final String assetName = R.assets.lottie.splashScreenJson(R.brightness);

  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(body: _buildBody());

  Widget _buildBody() => Center(
        child: AnimationPlayer.asset(
          assetName,
          onFinished: _splashScreenManager.onSplashScreenAnimationFinished,
        ),
      );
}
