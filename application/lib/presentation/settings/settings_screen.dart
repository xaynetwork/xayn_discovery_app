import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/extensions/subscription_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/payment/payment_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_details_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/subscripton_section.dart';
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
    final buildSubscriptionSection =
        state.subscriptionStatus.isSubscriptionActive ||
            state.subscriptionStatus.isFreeTrialActive;
    final children = [
      if (state.isPaymentEnabled && buildSubscriptionSection)
        _buildSubscriptionSection(state.subscriptionStatus),
      _buildAppThemeSection(
        appTheme: state.theme,
        isPaymentEnabled: state.isPaymentEnabled,
      ),
      _buildOptionsSection(state.isTtsEnabled),
      _buildBottomSpace(),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map(withPadding).toList(growable: false),
    );
    return SingleChildScrollView(child: column);
  }

  Widget _buildSubscriptionSection(SubscriptionStatus subscriptionStatus) =>
      SubscriptionSection(
        subscriptionStatus: subscriptionStatus,
        onPressed: () => _onSubscriptionSectionPressed(subscriptionStatus),
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

  Widget _buildBottomSpace() => SizedBox(height: R.dimen.navBarHeight * 2);

  void _onSubscriptionSectionPressed(SubscriptionStatus subscriptionStatus) {
    if (subscriptionStatus.isSubscriptionActive) {
      showAppBottomSheet(
        context,
        builder: (_) => SubscriptionDetailsBottomSheet(
          subscriptionStatus: subscriptionStatus,
        ),
      );
    } else if (subscriptionStatus.isFreeTrialActive) {
      showAppBottomSheet(
        context,
        builder: (_) => PaymentBottomSheet(),
      );
    }
  }
}
