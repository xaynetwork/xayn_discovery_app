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
  setUp(() {
    repository = MockAppSettingsRepository();
    useCase = ListenDiscoveryFeedAxisUseCase(repository);

    final settingsWithHorizontalAxis = AppSettings.initial()
        .copyWith(discoveryFeedAxis: DiscoveryFeedAxis.horizontal);
    when(repository.settings).thenAnswer((_) => settingsWithHorizontalAxis);
    when(repository.watch()).thenAnswer(
      (_) => Stream.value(
        ChangedEvent(
          newObject: settingsWithHorizontalAxis,
          id: settingsWithHorizontalAxis.id,
        ),
      ),
    );
  });
  useCaseTest<ListenDiscoveryFeedAxisUseCase, None, DiscoveryFeedAxis>(
    'WHEN repository emit new value THEN useCase emit it as well',
    build: () => useCase,
    input: [none],
    expect: [useCaseSuccess(DiscoveryFeedAxis.horizontal)],
  );
}
