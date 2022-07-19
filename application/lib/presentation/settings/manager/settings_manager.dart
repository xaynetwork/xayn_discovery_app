import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/app_shared_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/app_theme_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bug_reported_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/feedback_given_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_subscription_window_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/subscription_action_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/bug_reporting/bug_reporting_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/notifications/local_notifications_service.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
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
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/redeem_promo_code_mixin.dart';
import 'package:xayn_discovery_app/presentation/payment/util/observe_subscription_window_mixin.dart';
import 'package:xayn_discovery_app/presentation/rating_dialog/manager/rating_dialog_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/open_external_url_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';

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
        OverlayManagerMixin<SettingsScreenState>,
        RedeemPromoCodeMixin<SettingsScreenState>
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
  final LocalNotificationsService _localNotificationsService;
  final DiscoveryFeedManager _discoveryFeedManager;

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
    this._localNotificationsService,
    this._discoveryFeedManager,
  ) : super(const SettingsScreenState.initial()) {
    _init();
  }

  bool _initDone = false;
  late AppTheme _theme;
  late final AppVersion _appVersion;
  late SubscriptionStatus _subscriptionStatus;
  late final UseCaseValueStream<AppTheme> _appThemeHandler =
      consume(_listenAppThemeUseCase, initialData: none);
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
      _subscriptionStatus =
          await _getSubscriptionStatusUseCase.singleOutput(none);

      _initDone = true;
    });
  }

  void saveTheme(AppTheme theme) {
    _saveAppThemeUseCase(theme);
    _sendAnalyticsUseCase(AppThemeChangedEvent(theme: theme));
  }

  Future<void> extractLogs() => _extractLogUseCase.call(none);

  void reportBug() {
    _bugReportingService.reportBug(
      brightness: R.brightness,
      primaryColor: R.colors.primaryAction,
    );
    _sendAnalyticsUseCase(BugReportedEvent());
  }

  void giveFeedback() {
    _bugReportingService.giveFeedback(
      brightness: R.brightness,
      primaryColor: R.colors.primaryAction,
    );
    _sendAnalyticsUseCase(FeedbackGivenEvent());
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
          appVersion: _appVersion,
          isPaymentEnabled: _featureManager.isPaymentEnabled,
          arePushNotificationDeepLinksEnabled:
              _featureManager.arePushNotificationDeepLinksEnabled,
          subscriptionStatus: _subscriptionStatus,
        );
    return fold2(
      _appThemeHandler,
      _subscriptionStatusHandler,
    ).foldAll((appTheme, subscriptionStatus, _) async {
      if (appTheme != null) {
        _theme = appTheme;
      }

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
          onRedeemPressed: _featureManager.isAlternativePromoCodeEnabled
              ? redeemAlternativeCodeFlow
              : null,
        ),
      );
    }
  }

  void requestNotificationPermission() =>
      _localNotificationsService.requestPermission();

  void sendTestPushNotification() async {
    if (_discoveryFeedManager.state.cards.isEmpty) return;
    final card = _discoveryFeedManager.state.cards.first;
    final document = card.document;
    if (document == null) return;

    _localNotificationsService.sendNotification(
      title: document.resource.title,
      body: document.resource.snippet,
      documentId: UniqueId.fromTrustedString(document.documentId.toString()),
      delay: const Duration(seconds: 5),
    );
  }
}
