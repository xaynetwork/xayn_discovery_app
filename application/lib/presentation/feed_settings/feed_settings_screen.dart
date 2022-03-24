import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source_filter_settings_page.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

class FeedSettingsScreen extends StatefulWidget {
  const FeedSettingsScreen({Key? key}) : super(key: key);

  @override
  FeedSettingsScreenState createState() => FeedSettingsScreenState();
}

class FeedSettingsScreenState extends State<FeedSettingsScreen>
    with NavBarConfigMixin {
  late final FeedSettingsManager _manager = di.get();
  late final FeatureManager _featureManager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(buildNavBarItemBack(
        onPressed: _manager.onBackNavPressed,
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.titleOnly(
            title: R.strings.feedSettingsScreenTabCountries,
          ),
        ),
        body: _buildBody(),
      );

  Widget _buildBody() {
    final countries = Padding(
      padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
      child: const CountryFeedSettingsPage(),
    );

    if (!_featureManager.isDocumentFilterEnabled) {
      return countries;
    }

    final pages = [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
        child: const SourceFilterSettingsPage(),
      ),
      countries,
    ];

    final tabBar = TabBar(
      isScrollable: true,
      padding: EdgeInsets.all(R.dimen.unit0_25),
      tabs: [
        Text(
          R.strings.feedSettingsScreenTabSources,
          style: R.styles.lStyle,
        ),
        Text(
          R.strings.feedSettingsScreenTabCountries,
          style: R.styles.lStyle,
        ),
      ],
    );
    final tabView = TabBarView(
      children: pages,
    );
    return DefaultTabController(
      length: pages.length,
      initialIndex: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: tabBar,
            height: 36,
          ),
          SizedBox(height: R.dimen.unit),
          Expanded(child: tabView),
        ],
      ),
    );
  }
}
