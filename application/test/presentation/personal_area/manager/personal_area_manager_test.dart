import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

import '../../settings/manager/settings_manager_test.mocks.dart';
import '../../test_utils/utils.dart';

void main() {
  late MockPersonalAreaNavActions actions;
  late PersonalAreaManager manager;
  final initialState = PersonalAreaState.initial();
  late UrlOpener urlOpener;

  setUp(() {
    di.allowReassignment = true;
    di.registerLazySingleton<SendAnalyticsUseCase>(
        () => SendAnalyticsUseCase(MockAnalyticsService()));
    urlOpener = MockUrlOpener();
    di.registerLazySingleton<UrlOpener>(() => urlOpener);
    actions = MockPersonalAreaNavActions();
    manager = PersonalAreaManager(actions);
  });

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN manager is created THEN state is initial',
    build: () => manager,
    verify: (manager) {
      expect(manager.state, equals(initialState));
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onHomeNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onHomeNavPressed(),
    verify: (manager) {
      verify(actions.onHomeNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onActiveSearchNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onActiveSearchNavPressed(),
    verify: (manager) {
      verify(actions.onActiveSearchNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onCollectionsNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onCollectionsNavPressed(),
    verify: (manager) {
      verify(actions.onCollectionsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onHomeFeedSettingsNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onHomeFeedSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onHomeFeedSettingsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );

  blocTest<PersonalAreaManager, PersonalAreaState>(
    'WHEN onSettingsNavPressed is called THEN redirected to action',
    build: () => manager,
    act: (manager) => manager.onSettingsNavPressed(),
    verify: (manager) {
      verify(actions.onSettingsNavPressed());
      verifyNoMoreInteractions(actions);
    },
  );
}
