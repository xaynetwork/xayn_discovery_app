import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';
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
    const page = CountryFeedSettingsPage();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
      child: page,
    );
  }
}
