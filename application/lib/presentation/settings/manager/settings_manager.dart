import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/get_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/listen_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/save_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';

abstract class SettingsNavActions {
  void onBackNavPressed();
}

@lazySingleton
class SettingsScreenManager extends Cubit<SettingsScreenState>
    with UseCaseBlocHelper<SettingsScreenState>
    implements SettingsNavActions {
  final FeatureManager _featureManager;
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SaveAppThemeUseCase _saveAppThemeUseCase;
  final ListenAppThemeUseCase _listenAppThemeUseCase;
  final SettingsNavActions _settingsNavActions;
  final GetTtsPreferenceUseCase _getTtsPreferenceUseCase;
  final SaveTtsPreferenceUseCase _saveTtsPreferenceUseCase;
  final ListenTtsPreferenceUseCase _listenTtsPreferenceUseCase;
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;

  SettingsScreenManager(
    this._getAppThemeUseCase,
    this._saveAppThemeUseCase,
    this._listenAppThemeUseCase,
    this._settingsNavActions,
    this._getTtsPreferenceUseCase,
    this._saveTtsPreferenceUseCase,
    this._listenTtsPreferenceUseCase,
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late bool _ttsPreference;
  late SubscriptionStatus _subscriptionStatus;
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
      _ttsPreference = await _getTtsPreferenceUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);
      _subscriptionStatus = await _getSubscriptionStatusUseCase
          .singleOutput(PurchasableIds.subscription);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) => _saveAppThemeUseCase(theme);

  void saveTextToSpeechPreference(bool ttsPreference) {
    _saveTtsPreferenceUseCase(ttsPreference);
  }

  @override
  Future<SettingsScreenState?> computeState() async {
    if (!_initDone) return null;
    SettingsScreenState buildReady() => SettingsScreenState.ready(
          theme: _theme,
          isPaymentEnabled: _featureManager.isPaymentEnabled,
          isTtsEnabled: _ttsPreference,
          subscriptionStatus: _subscriptionStatus,
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
