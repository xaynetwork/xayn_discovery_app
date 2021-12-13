import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/listen_discovery_feed_axis_use_case.dart';

import 'listen_discovery_feed_axis_use_case_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late MockAppSettingsRepository repository;
  late ListenDiscoveryFeedAxisUseCase useCase;

  final settingsWithHorizontalAxis = AppSettings.initial()
      .copyWith(discoveryFeedAxis: DiscoveryFeedAxis.horizontal);
  final settingsWithVerticalAxis = AppSettings.initial();

  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = ListenDiscoveryFeedAxisUseCase(repository);

    when(repository.settings).thenAnswer((_) => settingsWithHorizontalAxis);
  });

  useCaseTest<ListenDiscoveryFeedAxisUseCase, None, DiscoveryFeedAxis>(
    'WHEN repository emit single value THEN useCase emit it as well',
    setUp: () {
      when(repository.watch()).thenAnswer(
        (_) => Stream.value(
          ChangedEvent(
            newObject: settingsWithHorizontalAxis,
            id: settingsWithHorizontalAxis.id,
          ),
        ),
      );
    },
    build: () => useCase,
    input: [none],
    expect: [useCaseSuccess(DiscoveryFeedAxis.horizontal)],
  );

  useCaseTest<ListenDiscoveryFeedAxisUseCase, None, DiscoveryFeedAxis>(
    'WHEN repository emit multiple values THEN useCase emit them as well',
    setUp: () {
      when(repository.watch()).thenAnswer(
        (_) => Stream.fromIterable([
          ChangedEvent(
            newObject: settingsWithHorizontalAxis,
            id: settingsWithHorizontalAxis.id,
          ),
          ChangedEvent(
            newObject: settingsWithVerticalAxis,
            id: settingsWithVerticalAxis.id,
          ),
        ]),
      );
    },
    build: () => useCase,
    input: [none],
    expect: [
      useCaseSuccess(DiscoveryFeedAxis.horizontal),
      useCaseSuccess(DiscoveryFeedAxis.vertical),
    ],
  );
}
