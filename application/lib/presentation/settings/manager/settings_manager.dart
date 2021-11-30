import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/get_discovery_feed_scroll_direction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/save_discovery_feed_scroll_direction_use_case.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';

@lazySingleton
class SettingsScreenManager extends Cubit<SettingsScreenState>
    with UseCaseBlocHelper<SettingsScreenState> {
  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SaveAppThemeUseCase _saveAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final GetDiscoveryFeedScrollDirectionUseCase
      _getDiscoveryFeedScrollDirectionUseCase;
  final SaveDiscoveryFeedScrollDirectionCase
      _saveDiscoveryFeedScrollDirectionCase;

  SettingsScreenManager(
    this._getAppVersionUseCase,
    this._getAppThemeUseCase,
    this._saveAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._getDiscoveryFeedScrollDirectionUseCase,
    this._saveDiscoveryFeedScrollDirectionCase,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late final AppVersion _appVersion;
  late final DiscoveryFeedScrollDirection _discoveryFeedScrollDirection;
  late final UseCaseValueStream<AppTheme> _appThemeHandler;

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _appVersion = await _getAppVersionUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);
      _discoveryFeedScrollDirection =
          await _getDiscoveryFeedScrollDirectionUseCase.singleOutput(none);

      // attach listeners
      _appThemeHandler = consume(_listenAppThemeUseCase, initialData: none);

      _initDone = true;
    });
  }

  void changeTheme(AppTheme theme) => _saveAppThemeUseCase.call(theme);

  void changeScrollDirection(DiscoveryFeedScrollDirection scrollDirection) =>
      _saveDiscoveryFeedScrollDirectionCase.call(scrollDirection);

  void reportBug() {
    // todo: handle report bug
    //ignore: avoid_print
    print('report bug clicked');
  }

  void shareApp() {
    // todo: handle share app url/etc action
    //ignore: avoid_print
    print('shareApp clicked');
  }

  void openUrl(String url) {
    final uri = Uri.tryParse(url);
    assert(
      uri != null && uri.hasAuthority,
      'Please pass valid url. Current: $url',
    );
    // todo: handle open URL
    //ignore: avoid_print
    print('openUrl clicked. url: $url');
  }

  @override
  Future<SettingsScreenState?> computeState() async {
    if (!_initDone) return null;
    SettingsScreenState buildReady() => SettingsScreenState.ready(
          theme: _theme,
          appVersion: _appVersion,
          discoveryFeedScrollDirection: _discoveryFeedScrollDirection,
        );
    return fold(_appThemeHandler).foldAll((final appTheme, _) async {
      if (appTheme == _theme) {
        return null;
      }
      if (appTheme != null) {
        _theme = appTheme;
      }
      return buildReady();
    });
  }
}
