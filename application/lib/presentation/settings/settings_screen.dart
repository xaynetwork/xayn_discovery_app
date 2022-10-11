import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_improve_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/home_feed_settings_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/local_notifications_debug_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/notifications_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/remote_notifications_debug_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/share_app_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/subscripton_section.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

const _settingsNavBarConfigId = NavBarConfigId('settingsNavBarConfigId');

class _SettingsScreenState extends State<SettingsScreen>
    with
        NavBarConfigMixin,
        OverlayMixin<SettingsScreen>,
        WidgetsBindingObserver {
  late final SettingsScreenManager _manager = di.get();
  late final FeatureManager _featureManager = di.get();

  @override
  OverlayManager get overlayManager => _manager.overlayManager;

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        _settingsNavBarConfigId,
        buildNavBarItemBack(onPressed: _manager.onBackNavPressed),
      );

  Linden get linden => UnterDenLinden.getLinden(context);

  bool get _showDebugSecions =>
      EnvironmentHelper.kAppId != EnvironmentHelper.kReleaseAppId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _manager.onChangeAppLifecycleState(state);

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        appToolbarData: AppToolbarData.titleOnly(
          title: R.strings.settingsTitle,
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    Widget bloc = BlocBuilder<SettingsScreenManager, SettingsScreenState>(
      bloc: _manager,
      builder: _buildBlockState,
    );
    return ScreenStateSwitcher(child: bloc);
  }

  Widget _buildBlockState(BuildContext context, SettingsScreenState state) {
    final child = state.map(
      initial: (_) => const Center(),
      ready: _buildStateReady,
    );
    return ScreenStateSwitcher(child: child);
  }

  /// disabled TTS [_buildOptionsSection] to instead move it to the FeatureManager for now
  Widget _buildStateReady(SettingsScreenStateReady state) {
    Widget withPadding(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: child,
        );
    final buildSubscriptionSection =
        state.subscriptionStatus.isSubscriptionActive ||
            state.subscriptionStatus.isFreeTrialActive;
    final isBetaUser = state.subscriptionStatus.isBetaUser;
    final children = [
      if (state.isPaymentEnabled && buildSubscriptionSection && !isBetaUser)
        _buildSubscriptionSection(
          subscriptionStatus: state.subscriptionStatus,
        ),
      if (!_featureManager.isDemoModeEnabled)
        _buildHomeFeedSection(
          isPaymentEnabled: state.isPaymentEnabled,
          isTopicsEnabled: state.isTopicsEnabled,
        ),
      if (state.areRemoteNotificationsEnabled)
        _buildNotificationsSection(
          arePushNotificationsActive: state.arePushNotificationsActive,
        ),
      _buildAppThemeSection(
        appTheme: state.theme,
      ),
      _buildGeneralSection(),
      _buildHelpImproveSection(),
      _buildShareAppSection(),
      if (state.areLocalNotificationsEnabled && _showDebugSecions)
        _buildLocalNotificationDebugSection(),
      if (state.areRemoteNotificationsEnabled && _showDebugSecions)
        _buildRemoteNotificationDebugSection(),
      _buildAppVersion(state.appVersion),
      _buildBottomSpace(),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map(withPadding).toList(growable: false),
    );
    return SingleChildScrollView(child: column);
  }

  Widget _buildSubscriptionSection({
    required SubscriptionStatus subscriptionStatus,
  }) =>
      SubscriptionSection(
        subscriptionStatus: subscriptionStatus,
        onPressed: () => _manager.onSubscriptionSectionPressed(
          subscriptionStatus: subscriptionStatus,
        ),
      );

  Widget _buildHomeFeedSection({
    required bool isPaymentEnabled,
    required bool isTopicsEnabled,
  }) =>
      SettingsHomeFeedSection(
        isFirstSection: !isPaymentEnabled,
        isTopicsEnabled: isTopicsEnabled,
        onCountriesPressed: _manager.onCountriesOptionsPressed,
        onSourcesPressed: _manager.onSourcesOptionsPressed,
        onResetAIPressed: _manager.onResetAIPressed,
        onTopicsPressed: _manager.onTopicsOptionsPressed,
      );

  Widget _buildNotificationsSection({
    required bool arePushNotificationsActive,
  }) =>
      NotificationsSection(
        togglePushNotificationsState: _manager.togglePushNotificationsState,
        arePushNotificationsActive: arePushNotificationsActive,
      );

  Widget _buildAppThemeSection({
    required AppTheme appTheme,
  }) =>
      SettingsAppThemeSection(
        theme: appTheme,
        onSelected: _manager.saveTheme,
      );

  Widget _buildGeneralSection() => SettingsGeneralInfoSection(
        onAboutPressed: () => _manager.openExternalUrl(
          url: Constants.aboutXaynUrl,
          currentView: CurrentView.settings,
        ),
        onCarbonNeutralPressed: () => _manager.openExternalUrl(
          url: Constants.carbonNeutralUrl,
          currentView: CurrentView.settings,
        ),
        onImprintPressed: () => _manager.openExternalUrl(
          url: Constants.imprintUrl,
          currentView: CurrentView.settings,
        ),
        onPrivacyPressed: () => _manager.openExternalUrl(
          url: Constants.privacyPolicyUrl,
          currentView: CurrentView.settings,
        ),
        onTermsPressed: () => _manager.openExternalUrl(
          url: Constants.termsAndConditionsUrl,
          currentView: CurrentView.settings,
        ),
      );

  Widget _buildHelpImproveSection() => SettingsHelpImproveSection(
        onReportBugPressed: _manager.reportBug,
        onGiveFeedbackPressed: _manager.giveFeedback,
      );

  Widget _buildShareAppSection() =>
      ShareAppSection(onShareAppPressed: _manager.shareApp);

  Widget _buildLocalNotificationDebugSection() =>
      LocalNotificationsDebugSection(
        onRequestLocalNotificationPermissionPressed:
            _manager.requestLocalNotificationPermission,
        onSendTestLocalNotificationPressed: _manager.sendTestLocalNotification,
      );

  Widget _buildRemoteNotificationDebugSection() =>
      RemoteNotificationsDebugSection(
        onCopyChannelIdPressed: _manager.copyChannelId,
        onCopyUserIdPressed: _manager.copyUserId,
      );

  Widget _buildAppVersion(AppVersion appVersion) => GestureDetector(
        child: Padding(
          padding: EdgeInsets.only(top: R.dimen.unit4),
          child: Text(
            '${R.strings.settingsVersion} ${appVersion.version}\n'
            '${R.strings.settingsBuild} ${appVersion.build}',
            style: R.styles.mStyle.copyWith(
              color: R.colors.secondaryText,
            ),
          ),
        ),
        onLongPress: () {
          _manager.triggerHapticFeedbackMedium();
          _manager.extractLogs();
        },
      );

  Widget _buildBottomSpace() => SizedBox(height: R.dimen.navBarHeight * 2);
}
