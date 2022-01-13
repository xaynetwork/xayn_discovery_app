import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/reset_engine_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/reset_engine_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockDiscoveryEngine engine;

  setUp(() async {
    engine = MockDiscoveryEngine();

    di.registerSingletonAsync<ResetEngineUseCase>(
        () => Future.value(ResetEngineUseCase(engine)));

    when(engine.resetEngine()).thenAnswer(
      (_) => Future.value(const ClientEventSucceeded()),
    );
  });

  blocTest<_TestBloc, bool>(
    'WHEN changing configuration THEN this configuration is passed to the engine',
    build: () => _TestBloc(),
    act: (bloc) => bloc.resetEngine(),
    verify: (manager) {
      expect(manager.state, equals(false));
      verify(engine.resetEngine());
      verifyNoMoreInteractions(engine);
    },
  );
}

class _TestBloc extends Cubit<bool>
    with UseCaseBlocHelper<bool>, ResetEngineMixin<bool> {
  _TestBloc() : super(false);
}
