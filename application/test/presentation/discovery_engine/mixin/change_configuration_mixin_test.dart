import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_configuration_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/change_configuration_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();

    di.registerSingletonAsync<ChangeConfigurationUseCase>(
        () => Future.value(ChangeConfigurationUseCase(engine)));

    when(engine.changeConfiguration(
            feedMarket: anyNamed('feedMarket'),
            maxItemsPerFeedBatch: anyNamed('maxItemsPerFeedBatch')))
        .thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );
  });

  blocTest<TestBloc, bool>(
    'WHEN changing configuration THEN this configuration is passed to the engine',
    build: () => TestBloc(),
    act: (bloc) => bloc.changeConfiguration(
      feedMarket: 'test',
      maxItemsPerFeedBatch: 20,
    ),
    verify: (manager) {
      expect(manager.state, equals(false));
      verify(engine.changeConfiguration(
        feedMarket: 'test',
        maxItemsPerFeedBatch: 20,
      ));
      verifyNoMoreInteractions(engine);
    },
  );
}

class TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, ChangeConfigurationMixin<bool> {
  TestBloc() : super(false);
}
