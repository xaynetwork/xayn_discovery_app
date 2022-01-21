import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_configuration_mixin.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';

abstract class SettingsNavActions {
  void onBackNavPressed();
}

@lazySingleton
class SettingsScreenManager extends Cubit<SettingsScreenState>
    with
        UseCaseBlocHelper<SettingsScreenState>,
        ChangeConfigurationMixin<SettingsScreenState>
    implements SettingsNavActions {
  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SaveAppThemeUseCase _saveAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final BugReportingService _bugReportingService;
  final ExtractLogUseCase _extractLogUseCase;
  final SettingsNavActions _settingsNavActions;

  SettingsScreenManager(
    this._getAppVersionUseCase,
    this._getAppThemeUseCase,
    this._saveAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._bugReportingService,
    this._extractLogUseCase,
    this._settingsNavActions,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late final AppVersion _appVersion;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _appVersion = await _getAppVersionUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);

      // attach listeners
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) => _saveAppThemeUseCase.call(theme);

  Future<void> extractLogs() => _extractLogUseCase.call(none);

  void reportBug() => _bugReportingService.showDialog(
        brightness: R.brightness,
        primaryColor: R.colors.primaryAction,
      );

  void shareApp() {
    // todo: handle share app url/etc action
    //ignore: avoid_print
    print('shareApp clicked');
  }

  void openUrl(String url) async {
    final uri = Uri.tryParse(url);
    assert(
      uri != null && uri.hasAuthority,
      'Please pass valid url. Current: $url',
    );

    if (!await launch(url)) {
      //ignore: avoid_print
      print('Could not launch $url');
    }
  }

  @override
  Future<SettingsScreenState?> computeState() async {
    if (!_initDone) return null;
    SettingsScreenState buildReady() => SettingsScreenState.ready(
          theme: _theme,
          appVersion: _appVersion,
        );
    return fold(_appThemeHandler).foldAll((appTheme, _) async {
      if (appTheme != null) {
        _theme = appTheme;
      }

      return buildReady();
    });
  }

  @override
  void onBackNavPressed() => _settingsNavActions.onBackNavPressed();
}
