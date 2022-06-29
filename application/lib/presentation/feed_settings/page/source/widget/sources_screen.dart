import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/widget/sources_view.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class SourcesScreen extends StatefulWidget {
  const SourcesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> with NavBarConfigMixin {
  late final SourcesManager manager = di.get()..init();
  int _selectedTabIndex = 0;

  Error get indexError => ArgumentError.value(
        _selectedTabIndex,
        'could not resolve the correct tab index',
      );

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        const NavBarConfigId('sourcesNavBarConfigId'),
        buildNavBarItemBack(
          onPressed: manager.onDismissSourcesSelection,
        ),
      );

  @override
  void dispose() {
    manager.applyChanges();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        appToolbarData: AppToolbarData.titleOnly(
          title: R.strings.feedSettingsScreenTabSources,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: _buildBody(),
        ),
      );

  Widget _buildBody() {
    final body = Builder(
      builder: (context) {
        final tabController = DefaultTabController.of(context);

        tabController?.addListener(
            () => setState(() => _selectedTabIndex = tabController.index));

        return BlocBuilder<SourcesManager, SourcesState>(
          bloc: manager,
          builder: (_, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTabBar(),
              Divider(
                color: R.colors.divider,
                height: 1.0,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: R.dimen.unit2,
                  bottom: R.dimen.unit2_5,
                ),
                child: _buildInfoText(context),
              ),
              ..._buildButtonAndTabView(context, state),
            ],
          ),
        );
      },
    );

    return DefaultTabController(
      length: 2,
      initialIndex: _selectedTabIndex,
      child: body,
    );
  }

  List<Widget> _buildButtonAndTabView(
      BuildContext context, SourcesState state) {
    final button = Padding(
      padding: EdgeInsets.only(bottom: R.dimen.unit2_5),
      child: _buildAddSourceButton(context),
    );
    final tabView = Expanded(
      child: _buildTabBarView(state),
    );
    final empty = AnimationPlayer.asset(
        R.linden.assets.lottie.contextual.emptySourcesMgmt);

    if (_selectedTabIndex == 0) {
      final emptyInfo = Padding(
        padding: EdgeInsets.only(bottom: R.dimen.unit1_5),
        child: Center(
          child: Text(
            R.strings.noTrustedSourcesYet,
            style: R.styles.mBoldStyle,
          ),
        ),
      );

      return state.jointTrustedSources.isEmpty
          ? [empty, emptyInfo, button]
          : [button, tabView];
    }

    final emptyInfo = Padding(
      padding: EdgeInsets.only(bottom: R.dimen.unit1_5),
      child: Center(
        child: Text(
          R.strings.noExcludedSourcesYet,
          style: R.styles.mBoldStyle,
        ),
      ),
    );

    return state.jointExcludedSources.isEmpty
        ? [empty, emptyInfo, button]
        : [button, tabView];
  }

  Widget _buildTabBar() => AppTabBar(
        tabs: [
          Tab(text: R.strings.trustedSourcesTab),
          Tab(text: R.strings.excludedSourcesTab),
        ],
      );

  Widget _buildInfoText(BuildContext context) {
    if (_selectedTabIndex == 0) {
      return Text(R.strings.trustedSourcesDescription);
    } else if (_selectedTabIndex == 1) {
      return Text(R.strings.excludedSourcesDescription);
    }

    throw indexError;
  }

  Widget _buildAddSourceButton(BuildContext context) => AppRaisedButton.text(
        onPressed: () {
          if (_selectedTabIndex == 0) {
            return manager.onLoadTrustedSourcesInterface();
          } else if (_selectedTabIndex == 1) {
            return manager.onLoadExcludedSourcesInterface();
          }

          throw indexError;
        },
        text: R.strings.btnAdd,
      );

  Widget _buildTabBarView(SourcesState state) => TabBarView(
        children: [
          SourcesView.trustedSources(
            manager: manager,
            state: state,
          ),
          SourcesView.excludedSources(
            manager: manager,
            state: state,
          ),
        ],
      );
}
