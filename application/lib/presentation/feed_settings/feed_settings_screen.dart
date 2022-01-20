import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/animated_state_switcher.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar.dart';

class FeedSettingsScreen extends StatefulWidget {
  const FeedSettingsScreen({Key? key}) : super(key: key);

  @override
  FeedSettingsScreenState createState() => FeedSettingsScreenState();
}

class FeedSettingsScreenState extends State<FeedSettingsScreen>
    with NavBarConfigMixin {
  late final manager = di.get<FeedSettingsManager>();

  @override
  NavBarConfig get navBarConfig => NavBarConfig.backBtn(buildNavBarItemBack(
        onPressed: manager.onBackNavPressed,
      ));

  @override
  void initState() {
    manager.init();
    super.initState();
  }

  @override
  void dispose() {
    manager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppToolbar(yourTitle: R.strings.feedSettingsScreenTitle),
        body: _buildBody(),
      );

  Widget _buildBody() {
    Widget _buildBlockState(BuildContext context, FeedSettingsState state) {
      final child = state.map(
        initial: (_) => const Center(),
        ready: _buildStateReady,
      );
      return ScreenStateSwitcher(child: child);
    }

    return BlocBuilder<FeedSettingsManager, FeedSettingsState>(
      bloc: manager,
      builder: _buildBlockState,
    );
  }

  Widget _buildStateReady(FeedSettingsStateReady state) {
    final page = CountryFeedSettingsPage(
      maxSelectedCountryAmount: state.maxSelectedCountryAmount,
      selectedCountries: state.selectedCountries,
      unSelectedCountries: state.unSelectedCountries,
      onAddCountryPressed: manager.onAddCountryPressed,
      onRemoveCountryPressed: manager.onRemoveCountryPressed,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
      child: page,
    );
  }
}
