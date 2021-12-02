import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_imptrove_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/scroll_direction_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/share_app_section.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/your_toolbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsScreenManager _manager;
  late final Future<SettingsScreenManager> initManagerFuture;

  Linden get linden => UnterDenLinden.getLinden(context);

  @override
  void initState() {
    initManagerFuture = di.getAsync<SettingsScreenManager>();
    initManagerFuture.then((manager) {
      _manager = manager;
    });
    super.initState();
  }

  @override
  void dispose() {
    // SettingsScreenManager is lazySingleton, so we should NOT `close` it
    // _manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const YourToolbar(yourTitle: Strings.settingsTitle),
        body: _buildBody(),
      );

  Widget _buildBody() {
    Widget buildBloc() =>
        BlocBuilder<SettingsScreenManager, SettingsScreenState>(
          bloc: _manager,
          builder: _buildBlockState,
        );
    return FutureBuilder(
      future: initManagerFuture,
      builder: (_, snapshot) {
        final child = snapshot.data == null ? const Center() : buildBloc();
        return ScreenStateSwitcher(child: child);
      },
    );
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
      _buildAppThemeSection(state.theme),
      _buildScrollDirectionSection(state.axis),
      _buildGeneralSection(),
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

  Widget _buildAppThemeSection(AppTheme appTheme) => SettingsAppThemeSection(
        theme: appTheme,
        onSelected: _manager.changeTheme,
      );

  Widget _buildScrollDirectionSection(DiscoveryFeedAxis axis) =>
      SettingsScrollDirectionSection(
        axis: axis,
        onSelected: _manager.changeAxis,
      );

  Widget _buildGeneralSection() => SettingsGeneralInfoSection(
        onAboutPressed: () => _manager.openUrl('https://about.com'),
        onCarbonNeutralPressed: () =>
            _manager.openUrl('https://carbonNeutral.com'),
        onImprintPressed: () => _manager.openUrl('https://imprint.com'),
        onPrivacyPressed: () => _manager.openUrl('https://pp.com'),
        onTermsPressed: () => _manager.openUrl('https://tc.com'),
      );

  Widget _buildHelpImproveSection() =>
      SettingsHelpImproveSection(onFindBugPressed: _manager.reportBug);

  Widget _buildShareAppSection() =>
      ShareAppSection(onShareAppPressed: _manager.shareApp);

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
