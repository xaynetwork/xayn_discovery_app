import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_imptrove_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/share_app_section.dart';
import 'package:xayn_discovery_app/presentation/widget/your_toolbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Linden get linden => UnterDenLinden.getLinden(context);

  var appTheme = AppTheme.system;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: YourToolbar(yourTitle: Strings.settingsTitle),
        body: _buildBody(),
      );

  Widget _buildBody() {
    Widget withPadding(Widget child) => Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: child,
        );
    final children = [
      _buildAppThemeSection(appTheme),
      _buildGeneralSection(),
      _buildHelpImproveSection(),
      _buildShareAppSection(),
      _buildAppVersion(const AppVersion(version: '1.2.3', build: '321')),
      _buildBottomSpace(),
    ];

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map(withPadding).toList(growable: false),
    );
    return SingleChildScrollView(child: column);
  }

  Widget _buildAppThemeSection(AppTheme appTheme) => SettingsAppThemeSection(
        theme: appTheme,
        onSelected: (AppTheme newTheme) {
          setState(() {
            this.appTheme = newTheme;
          });
        },
      );

  Widget _buildGeneralSection() => SettingsGeneralInfoSection(
        onAboutPressed: () {},
        onCarbonNeutralPressed: () {},
        onImprintPressed: () {},
        onPrivacyPressed: () {},
        onTermsPressed: () {},
      );

  Widget _buildHelpImproveSection() => SettingsHelpImproveSection(
        onFindBugPressed: () {},
      );

  Widget _buildShareAppSection() => ShareAppSection(
        onShareAppPressed: () {},
      );

  Widget _buildAppVersion(AppVersion appVersion) => Padding(
        padding: EdgeInsets.symmetric(vertical: R.dimen.unit4),
        child: Text(
          '${Strings.settingsVersion} ${appVersion.version}\n'
          '${Strings.settingsBuild} ${appVersion.build}',
          style: R.styles.appBodyText,
        ),
      );

  Widget _buildBottomSpace() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SizedBox(height: R.dimen.buttonMinHeight + bottomPadding);
  }
}
