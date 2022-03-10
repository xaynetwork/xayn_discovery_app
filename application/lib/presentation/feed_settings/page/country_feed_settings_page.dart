import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/widget/country_item.dart';

typedef OnCountryPressed = Function(Country country);

class CountryFeedSettingsPage extends StatelessWidget {
  final int maxSelectedCountryAmount;
  final List<Country> selectedCountries;
  final List<Country> unSelectedCountries;
  final OnCountryPressed onAddCountryPressed;
  final OnCountryPressed onRemoveCountryPressed;

  CountryFeedSettingsPage({
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

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHint(),
          _verticalSpace,
          _buildTitle(R.strings.feedSettingsScreenActiveCountryListSubtitle),
          ..._buildActiveCountries(),
          _verticalSpace,
          _buildTitle(R.strings.feedSettingsScreenInActiveCountryListSubtitle),
          _buildInactiveCountries(context),
        ],
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

  Widget _buildInactiveCountries(BuildContext context) {
    final listView = ListView.builder(
      itemBuilder: (_, index) {
        final country = unSelectedCountries[index];
        return CountryItem(
          country: country,
          isSelected: false,
          onActionPressed: () => onAddCountryPressed(country),
        );
      },
      itemCount: unSelectedCountries.length,
      padding: EdgeInsets.only(bottom: R.dimen.navBarHeight * 2),
    );
    return Expanded(child: listView);
  }
}
