import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/fake_model.dart';
import 'package:xayn_discovery_app/presentation/navigation/screen/router/app_router.gr.dart';

abstract class ScreenController {
  void pop<T>({T? result});

  void openSearch();

  Future<ResultModel?> openAccount({
    required bool param,
  });

  void openHome();

  void openOnboarding();
}

@Singleton(as: ScreenController)
class ScreenControllerImpl implements ScreenController {
  StackRouter? _rootRouter;

  StackRouter get _router => _rootRouter!;

  /// should be done once, when first screen init
  void setRouter(StackRouter router) {
    if (_rootRouter != null) return;
    _rootRouter = router;
  }

  @override
  void pop<T>({T? result}) => _router.pop(result);

  @override
  Future<ResultModel?> openAccount({
    required bool param,
  }) async {
    final route = SettingsScreenRoute(exampleParam: param);
    final result = await _router.push(route);
    return result as ResultModel?;
  }

  @override
  void openHome() => _router.replace(const DiscoveryFeedRoute());

  @override
  void openSearch() => _router.replace(const ActiveSearchRoute());

  @override
  void openOnboarding() => _router.push(const OnBoardingScreenRoute());
}
