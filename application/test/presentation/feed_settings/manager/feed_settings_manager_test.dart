import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_state.dart';

import '../../test_utils/utils.dart';

part 'feed_settings_manager_test.utils.dart';

void main() {
  late MockFeedSettingsNavActions navActions;
  late FeedSettingsManager manager;

  setUp(() {
    navActions = MockFeedSettingsNavActions();
    manager = FeedSettingsManager(navActions);
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
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager onAddCountryPressed() called THEN emit state ready with one more selected country',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.onAddCountryPressed(germany);
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
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'WHEN manager onRemoveCountryPressed() called THEN emit state ready with minus one selected country',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.onAddCountryPressed(germany);
      manager.onRemoveCountryPressed(germany);
    },
    expect: () => [
      const FeedSettingsState.initial(),
      stateReady,
    ],
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'GIVEN manager onRemoveCountryPressed() called WHEN only one selected country THEN nothing happened',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.onRemoveCountryPressed(germany);
    },
    expect: () => [
      const FeedSettingsState.initial(),
      stateReady,
    ],
  );

  blocTest<FeedSettingsManager, FeedSettingsState>(
    'GIVEN 3 calls with onAddCountryPressed WHEN selected list country already contain one default THEN add only 2 first',
    build: () => manager,
    act: (manager) {
      manager.init();
      manager.onAddCountryPressed(germany);
      manager.onAddCountryPressed(austria);
      manager.onAddCountryPressed(spain);
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
  );
}
