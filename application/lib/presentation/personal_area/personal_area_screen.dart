import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/widget/personal_area_card.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar.dart';

class PersonalAreaScreen extends StatefulWidget {
  const PersonalAreaScreen({Key? key}) : super(key: key);

  @override
  PersonalAreaScreenState createState() => PersonalAreaScreenState();
}

class PersonalAreaScreenState extends State<PersonalAreaScreen>
    with NavBarConfigMixin {
  late final PersonalAreaManager _manager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig(
        [
          buildNavBarItemHome(
            onPressed: _manager.onHomeNavPressed,
          ),
          buildNavBarItemSearch(
            onPressed: _manager.onActiveSearchNavPressed,
          ),
          buildNavBarItemPersonalArea(
            isActive: true,
            onPressed: () {
              // nothing to do, we already on this screen :)
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final bloc = BlocBuilder<PersonalAreaManager, None>(
      bloc: _manager,
      builder: (_, __) => _buildScreen(),
    );
    return Scaffold(
      appBar: AppToolbar(yourTitle: R.strings.personalAreaTitle),
      body: bloc,
    );
  }

  Widget _buildScreen() {
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildItems(),
    );
    final bottomPadding = R.dimen.navBarHeight + R.dimen.unit2;
    final sidePadding = R.dimen.unit3;
    final withPadding = Padding(
      child: column,
      padding: EdgeInsets.fromLTRB(
        sidePadding,
        0,
        sidePadding,
        bottomPadding,
      ),
    );
    return SingleChildScrollView(child: withPadding);
  }

  List<Widget> _buildItems() => [
        _buildCollection(),
        _buildHomeFeed(),
        _buildSettings(),
      ]
          .map((e) => Padding(
                padding: EdgeInsets.only(bottom: R.dimen.unit2),
                child: e,
              ))
          .toList();

  PersonalAreaCard _buildCollection() => PersonalAreaCard(
        key: Keys.personalAreaCardCollections,
        title: R.strings.personalAreaCollections,
        color: R.colors.personalAreaCollections,
        svgIconPath: R.assets.icons.book,
        svgBackground: R.assets.graphics.formsOrange,
        onPressed: _manager.onCollectionsNavPressed,
      );

  PersonalAreaCard _buildHomeFeed() => PersonalAreaCard(
        key: Keys.personalAreaCardHomeFeed,
        title: R.strings.personalAreaHomeFeed,
        color: R.colors.personalAreaHomeFeed,
        svgIconPath: R.assets.icons.confetti,
        svgBackground: R.assets.graphics.formsGreen,
        onPressed: _manager.onHomeFeedSettingsNavPressed,
      );

  PersonalAreaCard _buildSettings() => PersonalAreaCard(
        key: Keys.personalAreaCardSettings,
        title: R.strings.personalAreaSettings,
        color: R.colors.personalAreaSettings,
        svgIconPath: R.assets.icons.gear,
        svgBackground: R.assets.graphics.formsPurple,
        onPressed: _manager.onSettingsNavPressed,
      );
}
