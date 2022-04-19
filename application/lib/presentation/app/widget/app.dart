import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:provider/provider.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_router.dart';
import 'package:xayn_discovery_app/presentation/utils/app_locale.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _Observer extends WidgetsBindingObserver {
  final AppManager _appManager;
  final BuildContext context;

  _Observer(this._appManager, this.context);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _appManager.onResume();
        break;
      case AppLifecycleState.paused:
        _appManager.onPause();
        break;
      default:
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _appManager.onChangedPlatformBrightness();
  }
}

class _AppState extends State<App> {
  late final AppManager _appManager = di.get();
  late final AppNavigationManager _navigatorManager = di.get();
  late final ApplicationTooltipController _applicationTooltipController =
      ApplicationTooltipController();
  late final _observer = _Observer(_appManager, context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp.router(
      theme: UnterDenLinden.getLinden(context).themeData,
      routeInformationParser: _navigatorManager.routeInformationParser,
      routerDelegate: AppRouter(_navigatorManager),
      localeListResolutionCallback: (systemLocales, supportedLocales) {
        final locales = systemLocales == null || systemLocales.isEmpty
            ? [const Locale('en', 'US')]
            : systemLocales;
        final appLocale = locales.first.toAppLocale();

        final currentLanguage = AppLanguageHelper.from(
          locale: appLocale,
        );

        Strings.switchTranslations(currentLanguage);
        _appManager.maybeUpdateDefaultCollectionName();
        Instabug.setLocale(currentLanguage.instabugLocale);

        return locales.first;
      },
    );

    final newLinden = R.linden.updateBrightness(_appManager.state.brightness);
    R.updateLinden(newLinden);

    /// This [BlocListener] just returns the [materialApp] and does not rebuild a new App
    /// on a new [AppState], in contrast It will trigger an Update of [UnterDenLinden] that will cause
    /// a rebuild only when the brightness is different. This is important to prevent additional rebuild
    /// passes.
    return BlocListener<AppManager, AppState>(
      bloc: _appManager,
      // CAREFUL the app should NOT rebuild on appState.isAppPaused, this would
      // cause unnecessary flickering
      listenWhen: (s1, s2) => s1.brightness != s2.brightness,
      listener: (bc, s) {
        UnterDenLinden.of(context).changeBrightness(s.brightness);
      },
      child: Provider<ApplicationTooltipController>.value(
        value: _applicationTooltipController,
        child: InAppNotification(child: materialApp),
      ),
    );
  }
}
