import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instabug_flutter/Instabug.dart';
import 'package:provider/provider.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/app_language.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_router.dart';
import 'package:xayn_discovery_app/presentation/utils/app_locale.dart';
import 'package:xayn_discovery_app/presentation/utils/app_theme_extension.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AppManager _appManager = di.get();
  late final AppNavigationManager _navigatorManager = di.get();
  late final ApplicationTooltipController _applicationTooltipController =
      ApplicationTooltipController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _changeBrightness(_appManager.state.appTheme);
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

        // TODO retrieve the last language from the app state
        // if (savedAppLanguageTag != null) {
        //   appLocale = convertLanguageTagToLocale(savedAppLanguageTag) ??
        //       locales?.first.toIntlLocale();
        // }

        final currentLanguage = AppLanguageHelper.from(
          locale: appLocale,
        );

        Strings.switchTranslations(currentLanguage);
        Instabug.setLocale(currentLanguage.instabugLocale);

        return locales.first;
      },
    );

    return BlocConsumer<AppManager, AppState>(
      bloc: _appManager,
      builder: (_, __) => Provider<ApplicationTooltipController>.value(
        value: _applicationTooltipController,
        child: materialApp,
      ),
      listener: (_, state) => _changeBrightness(state.appTheme),
    );
  }

  void _changeBrightness(AppTheme appTheme) {
    UnterDenLinden.of(context).changeBrightness(appTheme.brightness);
  }
}
