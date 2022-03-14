import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_details_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/urls.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_imptrove_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/share_app_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/subscripton_section.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with NavBarConfigMixin {
  late final SettingsScreenManager _manager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
      buildNavBarItemBack(onPressed: _manager.onBackNavPressed));

  Linden get linden => UnterDenLinden.getLinden(context);

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.titleOnly(
            title: R.strings.settingsTitle,
          ),
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

  Widget _buildStateReady(SettingsScreenStateReady state) {
    Widget withPadding(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: child,
        );
    final children = [
      if (state.isPaymentEnabled) _buildSubscriptionSection(state.trialEndDate),
      _buildAppThemeSection(
        appTheme: state.theme,
        isPaymentEnabled: state.isPaymentEnabled,
      ),
      _buildOptionsSection(state.isTtsEnabled),
      _buildGeneralSection(state.isPaymentEnabled),
      _buildHelpImproveSection(),
      _buildShareAppSection(),
      _buildAppVersion(state.appVersion),
      _buildBottomSpace(),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map(withPadding).toList(growable: false),
    );
    return SingleChildScrollView(child: column);
  }

  Widget _buildSubscriptionSection(DateTime? trialEndDate) =>
      SubscriptionSection(
        trialEndDate: trialEndDate,
        onSubscribePressed: _manager.onSubscribePressed,
        onShowDetailsPressed: _showSubscriptionDetailsBottomSheet,
      );

  Widget _buildAppThemeSection({
    required AppTheme appTheme,
    required bool isPaymentEnabled,
  }) =>
      SettingsAppThemeSection(
        theme: appTheme,
        onSelected: _manager.saveTheme,
        isFirstSection: !isPaymentEnabled,
      );

  Widget _buildOptionsSection(bool isTtsEnabled) => SettingsSection(
        title: R.strings.settingsSectionTitleOptions,
        items: [
          SettingsCardData.fromTile(SettingsTileData(
            title: R.strings.enableTextToSpeech,
            svgIconPath: R.assets.icons.speechBubbles,
            action:
                // ignore: DEPRECATED_MEMBER_USE
                SettingsTileActionSwitch(
              value: isTtsEnabled,
              onPressed: () =>
                  _manager.saveTextToSpeechPreference(!isTtsEnabled),
              key: Keys.settingsToggleTextToSpeechPreference,
            ),
          )),
        ],
      );

  Widget _buildGeneralSection(bool isPaymentEnabled) =>
      SettingsGeneralInfoSection(
        onAboutPressed: () => _manager.openExternalUrl(Urls.aboutXayn),
        onCarbonNeutralPressed: () =>
            _manager.openExternalUrl(Urls.carbonNeutral),
        onImprintPressed: () => _manager.openExternalUrl(Urls.imprint),
        onPrivacyPressed: () => _manager.openExternalUrl(Urls.privacyPolicy),
        onTermsPressed: () => _manager.openExternalUrl(Urls.termsAndConditions),
        onPaymentPressed:
            isPaymentEnabled ? _manager.onPaymentNavPressed : null,
      );

  Widget _buildHelpImproveSection() => SettingsHelpImproveSection(
        onFindBugPressed: _manager.reportBug,
      );

  Widget _buildShareAppSection() =>
      ShareAppSection(onShareAppPressed: _manager.shareApp);

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
        onLongPress: () => _manager.extractLogs(),
      );

  Widget _buildBottomSpace() => SizedBox(height: R.dimen.navBarHeight * 2);

  void _showSubscriptionDetailsBottomSheet() => showAppBottomSheet(
        context,
        builder: (buildContext) => SubscriptionDetailsBottomSheet(
          subscriptionType: SubscriptionType.paid,
          endDate: subscriptionEndDate,
        ),
      );
}
