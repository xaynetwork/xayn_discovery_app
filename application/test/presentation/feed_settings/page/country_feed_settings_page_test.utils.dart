part of 'country_feed_settings_page_test.dart';

const int maxSelectedCountryAmount = 3;

const keyUSA = Key('usa');
const keyDE = Key('de');
const keyNL = Key('nl');

const countryUSA = Country(
  name: 'USA',
  countryCode: 'US',
  // svgFlagAssetPath: 'packages/xayn_design/assets/illustrations/flag_usa.svg',
  svgFlagAssetPath: 'packages/xayn_design/assets/icons/cross.svg',
  langCode: 'en',
  key: keyUSA,
);
const countryGermany = Country(
  name: 'Germany',
  countryCode: 'DE',
  // svgFlagAssetPath:
  //     'packages/xayn_design/assets/illustrations/flag_germany.svg',
  svgFlagAssetPath: 'packages/xayn_design/assets/icons/cross.svg',
  langCode: 'de',
  key: keyDE,
);
const countryNetherlands = Country(
  name: 'Netherlands',
  countryCode: 'NL',
  // svgFlagAssetPath:
  //     'packages/xayn_design/assets/illustrations/flag_netherlands.svg',
  svgFlagAssetPath: 'packages/xayn_design/assets/icons/cross.svg',
  langCode: 'nl',
  key: keyNL,
);

Widget buildPage({
  List<Country> selectedCountries = const [countryUSA],
  List<Country> unSelectedCountries = const [
    countryGermany,
    countryNetherlands
  ],
  OnCountryPressed? onAddCountryPressed,
  OnCountryPressed? onRemoveCountryPressed,
}) =>
    CountryFeedSettingsPage(
      maxSelectedCountryAmount: maxSelectedCountryAmount,
      selectedCountries: selectedCountries,
      unSelectedCountries: unSelectedCountries,
      onAddCountryPressed: onAddCountryPressed ?? (_) {},
      onRemoveCountryPressed: onRemoveCountryPressed ?? (_) {},
    );
