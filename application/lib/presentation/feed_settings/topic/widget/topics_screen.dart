import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';
import 'package:xayn_discovery_app/presentation/widget/app_scaffold/app_scaffold.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> with NavBarConfigMixin {
  late final TopicsManager manager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(
        const NavBarConfigId('topicsNavBarConfigId'),
        buildNavBarItemBack(
          onPressed: manager.onDismissTopicsScreen,
        ),
      );

  @override
  Widget build(BuildContext context) => AppScaffold(
        resizeToAvoidBottomInset: false,
        appToolbarData: AppToolbarData.titleOnly(
          title: R.strings.feedSettingsScreenTabTopics,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: _buildBody(),
        ),
      );

  Widget _buildBody() => BlocBuilder<TopicsManager, TopicsState>(
        bloc: manager,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(R.strings.topicsScreenDescription),
            SizedBox(height: R.dimen.unit2),
            if (state.selectedTopics.isEmpty) ..._buildEmpty(),
            _buildAddSourceButton(context),
            SizedBox(height: R.dimen.unit2_5),
            ..._buildTopicsList(context, state),
          ],
        ),
      );

  List<Widget> _buildTopicsList(
    BuildContext context,
    TopicsState state,
  ) {
    return [];
  }

  List<Widget> _buildEmpty() {
    final animation = AnimationPlayer.asset(
        R.linden.assets.lottie.contextual.createCollection);
    final emptyInfo = Padding(
      padding: EdgeInsets.only(top: R.dimen.unit, bottom: R.dimen.unit2),
      child: Center(
        child: Text(
          R.strings.noTopicsYet,
          style: R.styles.lBoldStyle,
        ),
      ),
    );
    return [animation, emptyInfo];
  }

  Widget _buildAddSourceButton(BuildContext context) => AppRaisedButton.text(
        onPressed: manager.onAddTopic,
        text: R.strings.addTopicBtn,
      );
}
