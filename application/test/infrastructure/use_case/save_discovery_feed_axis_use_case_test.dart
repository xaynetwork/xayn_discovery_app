import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/save_discovery_feed_axis_use_case.dart';

import 'save_discovery_feed_axis_use_case_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late MockAppSettingsRepository repository;
  late SaveDiscoveryFeedAxisUseCase useCase;

  const axis = DiscoveryFeedAxis.horizontal;

  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = SaveDiscoveryFeedAxisUseCase(repository);
    when(repository.settings).thenAnswer((_) => AppSettings.initial());
  });

  test(
    'GIVEN axis to store WHEN call useCase as Future THEN update value in repository',
    () async {
      await useCase.call(axis);

      verifyInOrder([
        repository.settings,
        repository.settings =
            AppSettings.initial().copyWith(discoveryFeedAxis: axis),
      ]);
      verifyNoMoreInteractions(repository);
    },
  );
}
