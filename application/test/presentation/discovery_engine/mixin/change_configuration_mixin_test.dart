import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_configuration_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_configuration_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();

    di.registerSingletonAsync<ChangeConfigurationUseCase>(
        () => Future.value(ChangeConfigurationUseCase(engine)));

    when(engine.changeConfiguration(
            feedMarkets: anyNamed('feedMarkets'),
            maxItemsPerFeedBatch: anyNamed('maxItemsPerFeedBatch')))
        .thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );
  });

  blocTest<_TestBloc, bool>(
    'WHEN changing configuration THEN this configuration is passed to the engine',
    build: () => _TestBloc(),
    act: (bloc) => bloc.changeConfiguration(
      feedMarkets: {const FeedMarket(countryCode: 'DE', langCode: 'de')},
      maxItemsPerFeedBatch: 20,
    ),
    verify: (manager) {
      expect(manager.state, equals(false));
      verify(engine.changeConfiguration(
        feedMarkets: {const FeedMarket(countryCode: 'DE', langCode: 'de')},
        maxItemsPerFeedBatch: 20,
      ));
      verifyNoMoreInteractions(engine);
    },
  );
}

class _TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, ChangeConfigurationMixin<bool> {
  _TestBloc() : super(false);
}
