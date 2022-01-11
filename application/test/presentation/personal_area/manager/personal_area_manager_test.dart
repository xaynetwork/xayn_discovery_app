import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockPersonalAreaNavActions actions;
  late PersonalAreaManager manager;
  const initialState = none;

  setUp(() {
    actions = MockPersonalAreaNavActions();
    manager = PersonalAreaManager(actions);
  });

  blocTest<PersonalAreaManager, None>(
    'WHEN manager is created THEN state is initial',
    build: () => manager,
    verify: (manager) {
      expect(manager.state, equals(initialState));
    },
  );

  blocTest<PersonalAreaManager, None>(
    'WHEN onHomeNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onHomeNavPressed(),
    verify: (manager) {
      verify(actions.onHomeNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, None>(
    'WHEN onActiveSearchNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onActiveSearchNavPressed(),
    verify: (manager) {
      verify(actions.onActiveSearchNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, None>(
    'WHEN onCollectionsNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onCollectionsNavPressed(),
    verify: (manager) {
      verify(actions.onCollectionsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, None>(
    'WHEN onHomeFeedSettingsNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onHomeFeedSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onHomeFeedSettingsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, None>(
    'WHEN onSettingsNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onSettingsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );
}
