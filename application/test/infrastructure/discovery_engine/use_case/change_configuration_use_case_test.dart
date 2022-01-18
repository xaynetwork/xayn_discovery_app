import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_configuration_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

import '../../../presentation/test_utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();
  });

  void _setUpSuccess() => when(engine.changeConfiguration(
              feedMarkets: anyNamed('feedMarkets'),
              maxItemsPerFeedBatch: anyNamed('maxItemsPerFeedBatch')))
          .thenAnswer(
        (_) => Future.value(const ClientEventSucceeded()),
      );

  void _setUpFailure() => when(engine.changeConfiguration(
              feedMarkets: anyNamed('feedMarkets'),
              maxItemsPerFeedBatch: anyNamed('maxItemsPerFeedBatch')))
          .thenAnswer(
        (_) => Future.value(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse)),
      );

  group('Change configuration', () {
    useCaseTest(
      'WHEN changing the configuration THEN expect a ClientEventSucceeded ',
      setUp: () => _setUpSuccess(),
      build: () => ChangeConfigurationUseCase(engine),
      input: [
        Configuration(
          maxItemsPerFeedBatch: 20,
          feedMarkets: {const FeedMarket(countryCode: 'DE', langCode: 'de')},
        )
      ],
      expect: [useCaseSuccess(const ClientEventSucceeded())],
    );

    useCaseTest(
      'WHEN changing the configuration and something went wrong THEN expect a EngineExceptionRaised ',
      setUp: () => _setUpFailure(),
      build: () => ChangeConfigurationUseCase(engine),
      input: [
        Configuration(
            maxItemsPerFeedBatch: 20,
            feedMarkets: {const FeedMarket(countryCode: 'DE', langCode: 'de')})
      ],
      expect: [
        useCaseSuccess(const EngineExceptionRaised(
            EngineExceptionReason.wrongEventInResponse))
      ],
    );
  });
}
