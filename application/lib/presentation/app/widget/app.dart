import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_router.dart';
import 'package:xayn_discovery_app/presentation/utils/app_theme_extension.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppManager _appManager = di.get();
  late final AppNavigationManager _navigatorManager = di.get();

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp.router(
      theme: UnterDenLinden.getLinden(context).themeData,
      routeInformationParser: _navigatorManager.routeInformationParser,
      routerDelegate: AppRouter(_navigatorManager),
    );

    return BlocConsumer<AppManager, AppState>(
      bloc: _appManager,
      builder: (_, __) => materialApp,
      listener: (_, state) => _changeBrightness(state.appTheme),
    );
  }

  void _changeBrightness(AppTheme appTheme) {
    UnterDenLinden.of(context).changeBrightness(appTheme.brightness);
  }
}
