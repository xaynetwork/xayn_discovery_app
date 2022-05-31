import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_mode.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_feed_settings_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/app_shared_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/app_theme_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bug_reported_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/subscription_action_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/save_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/extract_log_usecase.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/share_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_management_url_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/get_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/listen_subscription_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/util/observe_subscription_window_mixin.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';

abstract class SettingsNavActions {
  void onBackNavPressed();

  void onCountriesOptionsPressed();

  void onSourcesOptionsPressed();
}

@lazySingleton
class SettingsScreenManager extends Cubit<SettingsScreenState>
    with
        UseCaseBlocHelper<SettingsScreenState>,
        OpenExternalUrlMixin<SettingsScreenState>,
        ObserveSubscriptionWindowMixin<SettingsScreenState>,
        OverlayManagerMixin<SettingsScreenState>
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
  final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  final ListenSubscriptionStatusUseCase _listenSubscriptionStatusUseCase;
  final HapticFeedbackMediumUseCase _hapticFeedbackMediumUseCase;
  final GetSubscriptionManagementUrlUseCase
      _getSubscriptionManagementUrlUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  final AppManager _appManager;
  final RatingDialogManager _ratingDialogManager;
  final CrudFeedSettingsUseCase _crudFeedSettingsUseCase;

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
    this._featureManager,
    this._getSubscriptionStatusUseCase,
    this._listenSubscriptionStatusUseCase,
    this._getSubscriptionManagementUrlUseCase,
    this._sendAnalyticsUseCase,
    this._appManager,
    this._ratingDialogManager,
    this._crudFeedSettingsUseCase,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late FeedSettings? _feedSettings;
  late final AppVersion _appVersion;
  late SubscriptionStatus _subscriptionStatus;
  late final UseCaseValueStream<AppTheme> _appThemeHandler =
      consume(_listenAppThemeUseCase, initialData: none);
  late final _listenFeedSettingsHandler = consume(
    _crudFeedSettingsUseCase,
    initialData: DbCrudIn.watch(FeedSettings.globalId),
  );

  late final UseCaseValueStream<SubscriptionStatus> _subscriptionStatusHandler =
      consume(
    _listenSubscriptionStatusUseCase,
    initialData: none,
  );

  void _init() async {
    scheduleComputeState(() async {
      // read values
      _appVersion = await _getAppVersionUseCase.singleOutput(none);
      _theme = await _getAppThemeUseCase.singleOutput(none);

      final getSettingsOut = await _crudFeedSettingsUseCase
          .singleOutput(DbCrudIn.get(FeedSettings.globalId));
      _feedSettings =
          getSettingsOut.mapOrNull<FeedSettings?>(single: (s) => s.value);

      _subscriptionStatus =
          await _getSubscriptionStatusUseCase.singleOutput(none);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) {
    _saveAppThemeUseCase(theme);
    _sendAnalyticsUseCase(AppThemeChangedEvent(theme: theme));
  }

  void saveFeedMode(FeedMode mode) async {
    if (_feedSettings == null) return;
    final settings = _feedSettings!.copyWith(feedMode: mode);
    _crudFeedSettingsUseCase(DbCrudIn.store(settings));
  }

  Future<void> extractLogs() => _extractLogUseCase.call(none);

  void reportBug() {
    _bugReportingService.showDialog(
      brightness: R.brightness,
      primaryColor: R.colors.primaryAction,
    );
    _sendAnalyticsUseCase(BugReportedEvent());
  }

  void shareApp() {
    _shareUriUseCase.call(Uri.parse(Constants.downloadUrl)).then((value) =>
        _appManager.registerStateTransitionCallback(
            AppTransitionConditions.returnToApp, () {
          /// the app returned after being in background maybe show the rating dialog.
          _ratingDialogManager.shareDocumentCompleted();
        }));
    _sendAnalyticsUseCase(AppSharedEvent());
  }

  void triggerHapticFeedbackMedium() => _hapticFeedbackMediumUseCase.call(none);

  Future<void> onSubscriptionLinkCancelTapped() async {
    final subscriptionManagementUrl =
        (await _getSubscriptionManagementUrlUseCase.singleOutput(none)).url;
    if (subscriptionManagementUrl != null) {
      _sendAnalyticsUseCase(
        SubscriptionActionEvent(
          action: SubscriptionAction.unsubscribe,
        ),
      );

      openExternalUrl(
        url: subscriptionManagementUrl,
        currentView: CurrentView.settings,
      );
    }
  }

  @override
  Future<SettingsScreenState?> computeState() async {
    if (!_initDone) return null;
    SettingsScreenState buildReady() => SettingsScreenState.ready(
          theme: _theme,
          feedMode: _feedSettings?.feedMode ?? FeedMode.stream,
          appVersion: _appVersion,
          isPaymentEnabled: _featureManager.isPaymentEnabled,
          subscriptionStatus: _subscriptionStatus,
        );
    return fold3(
      _appThemeHandler,
      _subscriptionStatusHandler,
      _listenFeedSettingsHandler,
    ).foldAll((appTheme, subscriptionStatus, feedSettingsOut, _) async {
      if (appTheme != null) {
        _theme = appTheme;
      }

      _feedSettings =
          feedSettingsOut?.mapOrNull<FeedSettings?>(single: (s) => s.value);

      if (subscriptionStatus != null) {
        _subscriptionStatus = subscriptionStatus;
      }

      return buildReady();
    });
  }

  @override
  void onBackNavPressed() => _settingsNavActions.onBackNavPressed();

  @override
  void onCountriesOptionsPressed() =>
      _settingsNavActions.onCountriesOptionsPressed();

  @override
  void onSourcesOptionsPressed() =>
      _settingsNavActions.onSourcesOptionsPressed();

  void onSubscriptionSectionPressed({
    required SubscriptionStatus subscriptionStatus,
  }) {
    if (subscriptionStatus.isSubscriptionActive) {
      showOverlay(
        OverlayData.bottomSheetSubscriptionDetails(
          subscriptionStatus: subscriptionStatus,
          onSubscriptionLinkCancelTapped: onSubscriptionLinkCancelTapped,
        ),
      );
    } else if (subscriptionStatus.isFreeTrialActive) {
      onSubscriptionWindowOpened(
        currentView: SubscriptionWindowCurrentView.settings,
      );
      showOverlay(
        OverlayData.bottomSheetPayment(
          onClosePressed: () => onSubscriptionWindowClosed(
            currentView: SubscriptionWindowCurrentView.settings,
          ),
        ),
      );
    }
  }
}
