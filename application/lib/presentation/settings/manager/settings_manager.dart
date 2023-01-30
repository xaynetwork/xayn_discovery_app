import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_id/get_user_id_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

abstract class SettingsNavActions {
  void onBackNavPressed();
}

@lazySingleton
class SettingsScreenManager extends Cubit<SettingsScreenState>
    with
        UseCaseBlocHelper<SettingsScreenState>,
        OpenExternalUrlMixin<SettingsScreenState>,
        OverlayManagerMixin<SettingsScreenState>
    implements SettingsNavActions {
  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SaveAppThemeUseCase _saveAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final BugReportingService _bugReportingService;
  final ExtractLogUseCase _extractLogUseCase;
  final SettingsNavActions _settingsNavActions;
  final ShareUriUseCase _shareUriUseCase;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final AppManager _appManager;
  final RatingDialogManager _ratingDialogManager;
  final GetUserIdUseCase _getUserIdUseCase;

  SettingsScreenManager(
    this._getAppVersionUseCase,
    this._getAppThemeUseCase,
    this._saveAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._bugReportingService,
    this._extractLogUseCase,
    this._settingsNavActions,
    this._shareUriUseCase,
    this._hapticFeedbackMediumUseCase,
    this._appManager,
    this._ratingDialogManager,
    this._getUserIdUseCase,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late final AppVersion _appVersion;
  late final UseCaseValueStream<AppTheme> _appThemeHandler =
      consume(_listenAppThemeUseCase, initialData: none);

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _appVersion = await _getAppVersionUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) {
    _saveAppThemeUseCase(theme);
  }

  Future<void> extractLogs() => _extractLogUseCase.call(none);

  void reportBug() {
    _bugReportingService.reportBug(
      brightness: R.brightness,
      primaryColor: R.colors.primaryAction,
    );
  }

  void giveFeedback() {
    _bugReportingService.giveFeedback(
      brightness: R.brightness,
      primaryColor: R.colors.primaryAction,
    );
  }

  void shareApp() {
    _shareUriUseCase.call(Uri.parse(Constants.downloadUrl)).then((value) =>
        _appManager.registerStateTransitionCallback(
            AppTransitionConditions.returnToApp, () {
          /// the app returned after being in background maybe show the rating dialog.
          _ratingDialogManager.shareDocumentCompleted();
        }));
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<SettingsScreenState?> computeState() async {
    if (!_initDone) return null;
    Future<SettingsScreenState> buildReady() async => SettingsScreenState.ready(
          theme: _theme,
          appVersion: _appVersion,
          arePushNotificationsActive: false,
          areLocalNotificationsEnabled: false,
          areRemoteNotificationsEnabled: false,
        );

    return fold(_appThemeHandler).foldAll((appTheme, _) async {
      if (appTheme != null) {
        _theme = appTheme;
      }

      return await buildReady();
    });
  }

  @override
  void onBackNavPressed() => _settingsNavActions.onBackNavPressed();

  void onChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      scheduleComputeState(() {});
    }
  }

  void copyUserId() async {
    final userId = await _getUserIdUseCase.singleOutput(none);
    Clipboard.setData(ClipboardData(text: userId));
  }
}
