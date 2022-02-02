import 'package:injectable/injectable.dart';

abstract class AppLoadingNavActions {
  void onSplashScreenAnimationFinished();
}

@injectable
class AppLoadingScreenManager implements AppLoadingNavActions {
  final AppLoadingNavActions _appLoadingNavActions;

  AppLoadingScreenManager(this._appLoadingNavActions);

  @override
  void onSplashScreenAnimationFinished() =>
      _appLoadingNavActions.onSplashScreenAnimationFinished();
}
