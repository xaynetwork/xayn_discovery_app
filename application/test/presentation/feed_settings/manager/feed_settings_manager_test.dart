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
  late MockGetSelectedCountriesUseCase getSelectedCountriesUseCase;
  late MockSaveSelectedCountriesUseCase saveSelectedCountriesUseCase;
  late FeedSettingsManager manager;
  final allCountries = selectedList + unSelectedList;

  setUp(() {
    navActions = MockFeedSettingsNavActions();
    getSupportedCountriesUseCase = MockGetSupportedCountriesUseCase();
    getSelectedCountriesUseCase = MockGetSelectedCountriesUseCase();
    saveSelectedCountriesUseCase = MockSaveSelectedCountriesUseCase();

    manager = FeedSettingsManager(
      navActions,
      getSupportedCountriesUseCase,
      getSelectedCountriesUseCase,
      saveSelectedCountriesUseCase,
    );

    when(getSupportedCountriesUseCase.singleOutput(none))
        .thenAnswer((_) async => allCountries);
    when(getSelectedCountriesUseCase.singleOutput(allCountries.toSet()))
        .thenAnswer((_) async => selectedList.toSet());
    when(saveSelectedCountriesUseCase.singleOutput(any))
        .thenAnswer((_) async => none);
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
      verify(getSelectedCountriesUseCase.singleOutput(allCountries.toSet()));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
      verifyNoMoreInteractions(getSelectedCountriesUseCase);
      verifyZeroInteractions(saveSelectedCountriesUseCase);
      verifyZeroInteractions(navActions);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager onAddCountryPressed() called THEN emit state ready with one more selected country',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(await manager.onAddCountryPressed(germany), isTrue);
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
      verify(saveSelectedCountriesUseCase.singleOutput({usa, germany}));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);

      verifyZeroInteractions(navActions);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager onRemoveCountryPressed() called THEN emit state ready with minus one selected country',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(await manager.onAddCountryPressed(germany), isTrue);
      expect(await manager.onRemoveCountryPressed(germany), isTrue);
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
        stateReady.copyWith(selectedCountries: selectedList),
      ];
    },
    verify: (_) {
      verifyInOrder([
        getSupportedCountriesUseCase.singleOutput(none),
        saveSelectedCountriesUseCase.singleOutput({usa}),
        saveSelectedCountriesUseCase.singleOutput({usa}),
      ]);
      verifyNoMoreInteractions(getSupportedCountriesUseCase);
      verifyZeroInteractions(navActions);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'GIVEN manager onRemoveCountryPressed() called WHEN only one selected country THEN nothing happened',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(await manager.onRemoveCountryPressed(germany), isTrue);
    },
    expect: () => [
      const FeedSettingsState.initial(),
      stateReady,
    ],
    verify: (_) {
      verify(getSupportedCountriesUseCase.singleOutput(none));
      verifyNoMoreInteractions(getSupportedCountriesUseCase);

      verifyZeroInteractions(saveSelectedCountriesUseCase);
      verifyZeroInteractions(navActions);
    },
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'GIVEN 3 calls with onAddCountryPressed WHEN selected list country already contain one default THEN add only 2 first',
    build: () => manager,
    act: (manager) async {
      await manager.init();
      expect(await manager.onAddCountryPressed(germany), isTrue);
      expect(await manager.onAddCountryPressed(austria), isTrue);
      expect(await manager.onAddCountryPressed(spain), isFalse);
    },
    expect: () {
      final unselected = List<Country>.from(unSelectedList);
      unselected.remove(germany);
      final unselected2 = List<Country>.from(unselected);
      unselected2.remove(austria);
      return [
        const FeedSettingsState.initial(),
        stateReady.copyWith(
          selectedCountries: [usa, germany],
          unSelectedCountries: unselected,
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
        saveSelectedCountriesUseCase.singleOutput({usa, germany, austria}),
        saveSelectedCountriesUseCase.singleOutput({usa, germany, austria}),
      ]);

      verifyNoMoreInteractions(getSupportedCountriesUseCase);
      verifyZeroInteractions(navActions);
    },
  );
}
