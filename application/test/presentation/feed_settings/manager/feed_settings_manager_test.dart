import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_state.dart';

import '../../test_utils/utils.dart';

part 'feed_settings_manager_test.utils.dart';

void main() {
  late MockFeedSettingsNavActions navActions;
  late MockGetSupportedCountriesUseCase getSupportedCountriesUseCase;
  late FeedSettingsManager manager;

  setUp(() {
    navActions = MockFeedSettingsNavActions();
    getSupportedCountriesUseCase = MockGetSupportedCountriesUseCase();
    manager = FeedSettingsManager(navActions, getSupportedCountriesUseCase);
    when(getSupportedCountriesUseCase.singleOutput(none))
        .thenAnswer((_) async => selectedList + unSelectedList);
  });

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager just created THEN emit initial state',
    build: () => manager,
    expect: () => const [FeedSettingsState.initial()],
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager init() called THEN emit state ready with countries',
    build: () => manager,
    act: (manager) => manager.init(),
    expect: () => const [
      FeedSettingsState.initial(),
      stateReady,
    ],
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager onAddCountryPressed() called THEN emit state ready with one more selected country',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(manager.onAddCountryPressed(germany), isTrue);
    },
    expect: () {
      final unselected = List<Country>.from(unSelectedList);
      unselected.remove(germany);
      return [
        const FeedSettingsState.initial(),
        stateReady.copyWith(
          selectedCountries: [usa, germany],
          unSelectedCountries: unselected,
        ),
      ];
    },
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager onRemoveCountryPressed() called THEN emit state ready with minus one selected country',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(manager.onAddCountryPressed(germany), isTrue);
      expect(manager.onRemoveCountryPressed(germany), isTrue);
    },
    expect: () => [
      const FeedSettingsState.initial(),
      stateReady,
    ],
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'GIVEN manager onRemoveCountryPressed() called WHEN only one selected country THEN nothing happened',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(manager.onRemoveCountryPressed(germany), isTrue);
    },
    expect: () => [
      const FeedSettingsState.initial(),
      stateReady,
    ],
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'GIVEN 3 calls with onAddCountryPressed WHEN selected list country already contain one default THEN add only 2 first',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(manager.onAddCountryPressed(germany), isTrue);
      expect(manager.onAddCountryPressed(austria), isTrue);
      expect(manager.onAddCountryPressed(spain), isTrue);
    },
    expect: () {
      final unselected = List<Country>.from(unSelectedList);
      unselected.remove(germany);
      unselected.remove(austria);
      return [
        const FeedSettingsState.initial(),
        stateReady.copyWith(
          selectedCountries: [usa, germany, austria],
          unSelectedCountries: unselected,
        ),
      ];
    },
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
    },
  );
}
