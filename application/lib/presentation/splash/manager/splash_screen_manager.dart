import 'package:injectable/injectable.dart';

abstract class SplashScreenNavActions {
  void onSplashScreenAnimationFinished();
}

@injectable
class SplashScreenManager implements SplashScreenNavActions {
  final SplashScreenNavActions _splashScreenNavActions;

  SplashScreenManager(this._splashScreenNavActions);

  @override
  void onSplashScreenAnimationFinished() =>
      _splashScreenNavActions.onSplashScreenAnimationFinished();
}
