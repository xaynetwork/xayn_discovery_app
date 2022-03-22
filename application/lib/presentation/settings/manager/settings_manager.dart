import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_management_url_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/get_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/listen_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/save_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';

abstract class SettingsNavActions {
  void onBackNavPressed();
}

@lazySingleton
class SettingsScreenManager extends Cubit<SettingsScreenState>
    with
        UseCaseBlocHelper<SettingsScreenState>,
        OpenExternalUrlMixin<SettingsScreenState>
    implements SettingsNavActions {
  final FeatureManager _featureManager;
  final GetAppVersionUseCase _getAppVersionUseCase;
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SaveAppThemeUseCase _saveAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final BugReportingService _bugReportingService;
  final ExtractLogUseCase _extractLogUseCase;
  final SettingsNavActions _settingsNavActions;
  final ShareUriUseCase _shareUriUseCase;
  final GetTtsPreferenceUseCase _getTtsPreferenceUseCase;
  final SaveTtsPreferenceUseCase _saveTtsPreferenceUseCase;
  final ListenTtsPreferenceUseCase _listenTtsPreferenceUseCase;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final GetSubscriptionManagementUrlUseCase
      _getSubscriptionManagementUrlUseCase;

  SettingsScreenManager(
    this._getAppVersionUseCase,
    this._getAppThemeUseCase,
    this._saveAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._bugReportingService,
    this._extractLogUseCase,
    this._settingsNavActions,
    this._shareUriUseCase,
    this._getTtsPreferenceUseCase,
    this._saveTtsPreferenceUseCase,
    this._listenTtsPreferenceUseCase,
    this._hapticFeedbackMediumUseCase,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._getSubscriptionManagementUrlUseCase,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late final AppVersion _appVersion;
  late bool _ttsPreference;
  late SubscriptionStatus _subscriptionStatus;
  late String? _subscriptionManagementUrl;
  late final UseCaseValueStream<AppTheme> _appThemeHandler =
      consume(_listenAppThemeUseCase, initialData: none);
  late final UseCaseValueStream<bool> _ttsPreferenceHandler =
      consume(_listenTtsPreferenceUseCase, initialData: none);
  late final UseCaseValueStream<SubscriptionStatus> _subscriptionStatusHandler =
      consume(
    _listenSubscriptionStatusUseCase,
    initialData: PurchasableIds.subscription,
  );

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _appVersion = await _getAppVersionUseCase.singleOutput(none);
      _ttsPreference = await _getTtsPreferenceUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);
      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);
      _subscriptionManagementUrl =
          await _getSubscriptionManagementUrlUseCase.singleOutput(none);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) => _saveAppThemeUseCase(theme);

  void saveTextToSpeechPreference(bool ttsPreference) {
    _saveTtsPreferenceUseCase(ttsPreference);
  }

  Future<void> extractLogs() => _extractLogUseCase.call(none);

  void reportBug() => _bugReportingService.showDialog(
        brightness: R.brightness,
        primaryColor: R.colors.primaryAction,
      );

  void shareApp() => _shareUriUseCase.call(Uri.parse(Constants.downloadUrl));

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  @override
  Future<SettingsScreenState?> computeState() async {
    if (!_initDone) return null;
    SettingsScreenState buildReady() => SettingsScreenState.ready(
          theme: _theme,
          appVersion: _appVersion,
          isPaymentEnabled: _featureManager.isPaymentEnabled,
          isTtsEnabled: _ttsPreference,
          subscriptionStatus: _subscriptionStatus,
          subscriptionManagementURL: _subscriptionManagementUrl,
        );
    return fold3(
      _appThemeHandler,
      _ttsPreferenceHandler,
      _subscriptionStatusHandler,
    ).foldAll((appTheme, ttsPreference, subscriptionStatus, _) async {
      if (appTheme != null) {
        _theme = appTheme;
      }

      if (ttsPreference != null) {
        _ttsPreference = ttsPreference;
      }

      if (subscriptionStatus != null) {
        _subscriptionStatus = subscriptionStatus;
      }

      return buildReady();
    });
  }

  @override
  void onBackNavPressed() => _settingsNavActions.onBackNavPressed();
}
