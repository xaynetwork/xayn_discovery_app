import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/feed_countries_changed_event.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/feed_settings_error.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_state.dart';

import '../../test_utils/utils.dart';

part 'country_feed_settings_manager_test.utils.dart';

void main() {
  late MockGetSupportedCountriesUseCase getSupportedCountriesUseCase;
  late MockGetSelectedCountriesUseCase getSelectedCountriesUseCase;
  late MockSaveSelectedCountriesUseCase saveSelectedCountriesUseCase;
  late MockSendAnalyticsUseCase sendAnalyticsUseCase;
  late CountryFeedSettingsManager manager;
  final allCountries = selectedList + unSelectedList;

  setUp(() {
    getSupportedCountriesUseCase = MockGetSupportedCountriesUseCase();
    getSelectedCountriesUseCase = MockGetSelectedCountriesUseCase();
    saveSelectedCountriesUseCase = MockSaveSelectedCountriesUseCase();
    sendAnalyticsUseCase = MockSendAnalyticsUseCase();

    manager = CountryFeedSettingsManager(
      getSupportedCountriesUseCase,
      getSelectedCountriesUseCase,
      saveSelectedCountriesUseCase,
      sendAnalyticsUseCase,
    );

    when(getSupportedCountriesUseCase.singleOutput(none))
        .thenAnswer((_) async => allCountries);
    when(getSelectedCountriesUseCase.singleOutput(allCountries.toSet()))
        .thenAnswer((_) async => selectedList.toSet());
    when(saveSelectedCountriesUseCase.singleOutput(any))
        .thenAnswer((_) async => none);
  });

  blocTest<CountryFeedSettingsManager, CountryFeedSettingsState>(
    'WHEN manager just created THEN emit initial state',
    build: () => manager,
    expect: () => const [CountryFeedSettingsState.initial()],
  );

  blocTest<CountryFeedSettingsManager, CountryFeedSettingsState>(
    'WHEN manager init() called THEN emit state ready with countries',
    build: () => manager,
    act: (manager) => manager.init(),
    expect: () => const [
      CountryFeedSettingsState.initial(),
      stateReady,
    ],
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verify(getSelectedCountriesUseCase.singleOutput(allCountries.toSet()));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
      verifyNoMoreInteractions(getSelectedCountriesUseCase);
      verifyZeroInteractions(saveSelectedCountriesUseCase);
    },
  );

  blocTest<CountryFeedSettingsManager, CountryFeedSettingsState>(
    'WHEN manager onAddCountryPressed() called THEN emit state ready with one more selected country',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      await manager.onAddCountryPressed(germany);
    },
    expect: () {
      final unselected = List<Country>.from(unSelectedList);
      unselected.remove(germany);
      return [
        const CountryFeedSettingsState.initial(),
        stateReady.copyWith(
          selectedCountries: [usa, germany],
          unSelectedCountries: unselected,
        ),
      ];
    },
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verify(saveSelectedCountriesUseCase.singleOutput({usa, germany}));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );

  blocTest<CountryFeedSettingsManager, CountryFeedSettingsState>(
    'WHEN manager onRemoveCountryPressed() called THEN emit state ready with minus one selected country',
    build: () => manager,
    setUp: () {
      when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
            UseCaseResult.success(
              FeedCountriesChangedEvent(countries: {usa, germany}),
            ),
            UseCaseResult.success(
              FeedCountriesChangedEvent(countries: {usa}),
            ),
          ]);
    },
    act: (manager) async {
      await manager.init();
      await manager.onAddCountryPressed(germany);
      await manager.onRemoveCountryPressed(germany);
    },
    expect: () {
      final unselected = List<Country>.from(unSelectedList);
      unselected.remove(germany);
      return [
        const CountryFeedSettingsState.initial(),
        stateReady.copyWith(
          selectedCountries: [usa, germany],
          unSelectedCountries: unselected,
        ),
        stateReady.copyWith(selectedCountries: selectedList),
      ];
    },
    verify: (_) {
      verifyInOrder([
        getSupportedCountriesUseCase.singleOutput(none),
        saveSelectedCountriesUseCase.singleOutput({usa, germany}),
        saveSelectedCountriesUseCase.singleOutput({usa}),
      ]);
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );

  blocTest<CountryFeedSettingsManager, CountryFeedSettingsState>(
    'GIVEN manager onRemoveCountryPressed() called WHEN only one selected country THEN nothing happened',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      await manager.onRemoveCountryPressed(germany);
    },
    expect: () => [
      const CountryFeedSettingsState.initial(),
      stateReady.copyWith(
        error: const ErrorObject(FeedSettingsError.minSelectedCountries),
      ),
      stateReady,
    ],
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);

      verifyZeroInteractions(saveSelectedCountriesUseCase);
    },
  );

  blocTest<CountryFeedSettingsManager, CountryFeedSettingsState>(
    'GIVEN 3 calls with onAddCountryPressed WHEN selected list country already contain one default THEN add only 2 first',
    build: () => manager,
    setUp: () {
      when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
            UseCaseResult.success(
              FeedCountriesChangedEvent(countries: {usa, germany}),
            ),
            UseCaseResult.success(
              FeedCountriesChangedEvent(countries: {usa, germany, austria}),
            ),
          ]);
    },
    act: (manager) async {
      await manager.init();
      await manager.onAddCountryPressed(germany);
      await manager.onAddCountryPressed(austria);
      await manager.onAddCountryPressed(spain);
    },
    expect: () {
      final unselected = List<Country>.from(unSelectedList);
      unselected.remove(germany);
      final unselected2 = List<Country>.from(unselected);
      unselected2.remove(germany);
      unselected2.remove(austria);
      return [
        const CountryFeedSettingsState.initial(),
        stateReady.copyWith(
          selectedCountries: [usa, germany],
          unSelectedCountries: unselected,
        ),
        stateReady.copyWith(
          selectedCountries: [usa, germany, austria],
          unSelectedCountries: unselected2,
        ),
        stateReady.copyWith(
          selectedCountries: [usa, germany, austria],
          unSelectedCountries: unselected2,
          error: const ErrorObject(FeedSettingsError.maxSelectedCountries),
        ),
        stateReady.copyWith(
          selectedCountries: [usa, germany, austria],
          unSelectedCountries: unselected2,
        ),
      ];
    },
    verify: (_) {
      verifyInOrder([
        getSupportedCountriesUseCase.singleOutput(none),
        saveSelectedCountriesUseCase.singleOutput({usa, germany}),
        saveSelectedCountriesUseCase.singleOutput({usa, germany, austria}),
      ]);

      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );
}
