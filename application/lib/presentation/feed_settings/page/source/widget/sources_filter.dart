import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/widget/sources_view.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class SourcesFilter extends StatefulWidget {
  const SourcesFilter({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SourcesFilterState();
}

class _SourcesFilterState extends State<SourcesFilter> {
  late final SourcesManager manager = di.get()..init();

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
          child: _buildBody(context),
        ),
      );

  Widget _buildBody(BuildContext context) {
    final body = Column(
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
          child: _buildInfoText(),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: R.dimen.unit2_5),
          child: _buildAddSourceButton(),
        ),
        Expanded(
          child: BlocBuilder<SourcesManager, SourcesState>(
            bloc: manager,
            builder: (_, state) => _buildTabBarView(state),
          ),
        ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: body,
    );
  }

  Widget _buildTabBar() => const AppTabBar(
        tabs: [
          Tab(text: 'Trusted Sources'),
          Tab(text: 'Disliked Sources'),
        ],
      );

  Widget _buildInfoText() => const Text(
      'Sources that you like or dislike will no longer appear in your home feed');

  Widget _buildAddSourceButton() => AppRaisedButton.text(
        onPressed: () => manager.addSourceToExcludedList(
            Source('google${DateTime.now().millisecondsSinceEpoch}.com')),
        text: 'add',
      );

  Widget _buildTabBarView(SourcesState state) => TabBarView(
        children: [
          SourcesView.excludedSources(manager: manager, state: state),
          SourcesView.trustedSources(manager: manager, state: state),
        ],
      );
}
