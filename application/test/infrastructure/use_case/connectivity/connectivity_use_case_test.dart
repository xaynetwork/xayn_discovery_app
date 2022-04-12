import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';

import '../../../test_utils/mocks.mocks.dart';

const isConnectivityError = TypeMatcher<ConnectivityError>();

void main() {
  setUp(() {
    di.allowReassignment = true;
  });

  group('ConnectivityUseCaseMixin: ', () {
    test('WHEN connection is up THEN runs parent use case', () {
      final connectivityObserver = MockConnectivityObserver();

      when(connectivityObserver.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(connectivityObserver.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

      di.registerLazySingleton<ConnectivityObserver>(
          () => connectivityObserver);

      final data = Stream.value('echo');
      final useCase = _TestUseCase();
      final stream = data.switchedBy(useCase);

      expect(stream, emitsInOrder(['echo', emitsDone]));
    });

    test('WHEN connection is down THEN emits ConnectivityError', () {
      final connectivityObserver = MockConnectivityObserver();

      when(connectivityObserver.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(connectivityObserver.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.none));

      di.registerLazySingleton<ConnectivityObserver>(
          () => connectivityObserver);

      final data = Stream.value('echo');
      final useCase = _TestUseCase();
      final stream = data.switchedBy(useCase);

      expect(stream, emitsInOrder([emitsError(isConnectivityError)]));
    });

    test(
        'WHEN connection is down, but later restored THEN emits ConnectivityError followed by parent use case',
        () {
      final connectivityObserver = MockConnectivityObserver();

      when(connectivityObserver.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(connectivityObserver.onConnectivityChanged)
          .thenAnswer((_) => Stream.fromIterable(const [
                ConnectivityResult.none, // error
                ConnectivityResult.wifi, // runs parent use case
                ConnectivityResult.none, // never gets here
              ]));

      di.registerLazySingleton<ConnectivityObserver>(
          () => connectivityObserver);

      final data = Stream.fromIterable(['marco', 'polo']);
      final useCase = _TestUseCase();
      final stream = data.switchedBy(useCase);

      // note that the connectivity cycle of none -> wifi is played for every source event!
      expect(
          stream,
          emitsInOrder([
            emitsError(isConnectivityError),
            'marco',
            emitsError(isConnectivityError),
            'polo',
            emitsDone,
          ]));
    });
  });
}

class _TestUseCase extends UseCase<String, String>
    with ConnectivityUseCaseMixin<String, String> {
  @override
  Stream<String> transaction(String param) async* {
    yield param;
  }
}
