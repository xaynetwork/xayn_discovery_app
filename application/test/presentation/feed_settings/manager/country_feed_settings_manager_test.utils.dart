part of 'country_feed_settings_manager_test.dart';

const keyUsa = Key('keyUsa');
const keyGermany = Key('keyGermany');
const keyAustria = Key('keyAustria');
const keyFrance = Key('keyFrance');
const keyBelgiumFR = Key('keyBelgiumFR');
const keyBelgiumNL = Key('keyBelgiumNL');
const keySpain = Key('keySpain');

const usa = Country(
  name: 'USA',
  countryCode: 'US',
  svgFlagAssetPath: 'packages/xayn_design/assets/illustrations/flag_usa.svg',
  langCode: 'en',
  key: keyUsa,
);
const germany = Country(
  name: 'Germany',
  countryCode: 'DE',
  svgFlagAssetPath:
      'packages/xayn_design/assets/illustrations/flag_germany.svg',
  langCode: 'de',
  key: keyGermany,
);
const austria = Country(
  name: 'Austria',
  countryCode: 'AU',
  svgFlagAssetPath:
      'packages/xayn_design/assets/illustrations/flag_austria.svg',
  langCode: 'de',
  key: keyAustria,
);
const france = Country(
  name: 'France',
  countryCode: 'FR',
  svgFlagAssetPath: 'packages/xayn_design/assets/illustrations/flag_france.svg',
  langCode: 'fr',
  key: keyFrance,
);
const belgiumFR = Country(
  name: 'Belgium',
  countryCode: 'BE',
  svgFlagAssetPath:
      'packages/xayn_design/assets/illustrations/flag_belgium.svg',
  langCode: 'fr',
  language: 'French',
  key: keyBelgiumFR,
);
const belgiumNL = Country(
  name: 'Belgium',
  countryCode: 'BE',
  svgFlagAssetPath:
      'packages/xayn_design/assets/illustrations/flag_belgium.svg',
  langCode: 'nl',
  language: 'Dutch',
  key: keyBelgiumNL,
);
const spain = Country(
  name: 'Spain',
  countryCode: 'SP',
  svgFlagAssetPath: 'packages/xayn_design/assets/illustrations/flag_spain.svg',
  langCode: 'SP',
  key: keySpain,
);

const selectedList = [usa];
const unSelectedList = [
  germany,
  austria,
  france,
  belgiumFR,
  belgiumNL,
  spain,
];

const stateReady = CountryFeedSettingsState.ready(
  maxSelectedCountryAmount: maxSelectedCountryAmount,
  selectedCountries: selectedList,
  unSelectedCountries: unSelectedList,
) as CountryFeedSettingsStateReady;
