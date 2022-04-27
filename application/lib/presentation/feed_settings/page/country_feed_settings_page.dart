import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/widget/country_item.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

typedef OnCountryPressed = Function(Country country);

class CountryFeedSettingsPage extends StatefulWidget {
  const CountryFeedSettingsPage({Key? key}) : super(key: key);

  @override
  State<CountryFeedSettingsPage> createState() =>
      _CountryFeedSettingsPageState();
}

class _CountryFeedSettingsPageState extends State<CountryFeedSettingsPage>
    with OverlayMixin<CountryFeedSettingsPage> {
  late final CountryFeedSettingsManager _manager = di.get();

  @override
  OverlayManager get overlayManager => _manager.overlayManager;

  @override
  void initState() {
    _manager.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppToolbar(
          appToolbarData: AppToolbarData.titleOnly(
            title: R.strings.feedSettingsScreenTabCountries,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.dimen.unit3),
          child: _buildBody(context),
        ),
      );

  Widget _buildBody(BuildContext context) {
    Widget buildReadyState(CountryFeedSettingsStateReady ready) {
      return SelectCountries(
        maxSelectedCountryAmount: ready.maxSelectedCountryAmount,
        selectedCountries: ready.selectedCountries,
        unSelectedCountries: ready.unSelectedCountries,
        onAddCountryPressed: _manager.onAddCountryPressed,
        onRemoveCountryPressed: _manager.onRemoveCountryPressed,
      );
    }

    return BlocBuilder<CountryFeedSettingsManager, CountryFeedSettingsState>(
      bloc: _manager,
      builder: (_, state) => state.map(
        initial: (state) => const Center(),
        ready: buildReadyState,
      ),
    );
  }
}

class SelectCountries extends StatelessWidget {
  final int maxSelectedCountryAmount;
  final List<Country> selectedCountries;
  final List<Country> unSelectedCountries;
  final OnCountryPressed onAddCountryPressed;
  final OnCountryPressed onRemoveCountryPressed;

  SelectCountries({
    required this.maxSelectedCountryAmount,
    required this.selectedCountries,
    required this.unSelectedCountries,
    required this.onAddCountryPressed,
    required this.onRemoveCountryPressed,
    Key? key,
  }) : super(key: key) {
    assert(
      selectedCountries.isNotEmpty,
      'There should be at least one selected country',
    );
    assert(
      (selectedCountries + unSelectedCountries).toSet().length ==
          selectedCountries.length + unSelectedCountries.length,
      'All items should be unique',
    );
  }

  Widget get _verticalSpace => SizedBox(height: R.dimen.unit3);
  Widget get _scrollViewBottomSpace =>
      SizedBox(height: R.dimen.navBarHeight * 2);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHint(),
            _verticalSpace,
            _buildTitle(R.strings.feedSettingsScreenActiveCountryListSubtitle),
            ..._buildActiveCountries(),
            _verticalSpace,
            _buildTitle(
                R.strings.feedSettingsScreenInActiveCountryListSubtitle),
            ..._buildInactiveCountries(context),
            _scrollViewBottomSpace,
          ],
        ),
      );

  Widget _buildHint() => Text(
        R.strings.feedSettingsScreenContryListHint
            .format(maxSelectedCountryAmount.toString()),
        style: R.styles.mStyle,
      );

  Widget _buildTitle(String title) => Padding(
        padding: EdgeInsets.only(bottom: R.dimen.unit),
        child: Text(
          title,
          style: R.styles.lBoldStyle,
        ),
      );

  List<Widget> _buildActiveCountries() => selectedCountries
      .map((country) => CountryItem(
            country: country,
            isSelected: true,
            onActionPressed: () => onRemoveCountryPressed(country),
          ))
      .toList();

  List<Widget> _buildInactiveCountries(BuildContext context) =>
      unSelectedCountries
          .map((country) => CountryItem(
                country: country,
                isSelected: false,
                onActionPressed: () => onAddCountryPressed(country),
              ))
          .toList();
}
