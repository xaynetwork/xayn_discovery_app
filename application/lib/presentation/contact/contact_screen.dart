import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/urls.dart';
import 'package:xayn_discovery_app/presentation/contact/manager/contact_manager.dart';
import 'package:xayn_discovery_app/presentation/contact/manager/contact_state.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_imptrove_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/share_app_section.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with NavBarConfigMixin {
  late final ContactScreenManager _manager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
      buildNavBarItemBack(onPressed: _manager.onBackNavPressed));

  Linden get linden => UnterDenLinden.getLinden(context);

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.titleOnly(
            title: R.strings.personalAreaContact,
          ),
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    Widget bloc = BlocBuilder<ContactScreenManager, ContactScreenState>(
      bloc: _manager,
      builder: _buildBlockState,
    );
    return ScreenStateSwitcher(child: bloc);
  }

  Widget _buildBlockState(BuildContext context, ContactScreenState state) {
    final child = state.map(
      initial: (_) => const Center(),
      ready: _buildStateReady,
    );
    return ScreenStateSwitcher(child: child);
  }

  Widget _buildStateReady(ContactScreenStateReady state) {
    Widget withPadding(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: child,
        );
    final children = [
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

  Widget _buildGeneralSection(bool isPaymentEnabled) =>
      SettingsGeneralInfoSection(
        onAboutPressed: () =>
            _manager.openExternalUrl(Urls.aboutXayn, CurrentView.contact),
        onCarbonNeutralPressed: () =>
            _manager.openExternalUrl(Urls.carbonNeutral, CurrentView.contact),
        onImprintPressed: () =>
            _manager.openExternalUrl(Urls.imprint, CurrentView.contact),
        onPrivacyPressed: () =>
            _manager.openExternalUrl(Urls.privacyPolicy, CurrentView.contact),
        onTermsPressed: () => _manager.openExternalUrl(
            Urls.termsAndConditions, CurrentView.contact),
        onContactPressed: () =>
            _manager.openEmail(Urls.contactMail, CurrentView.contact),
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
}
