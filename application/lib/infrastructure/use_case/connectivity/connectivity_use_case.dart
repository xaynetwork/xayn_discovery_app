import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';

abstract class ConnectivityObserver {
  Stream<ConnectivityResult> get onConnectivityChanged;

  Future<ConnectivityResult> checkConnectivity();
}

@LazySingleton(as: ConnectivityObserver)
@releaseEnvironment
@debugEnvironment
class AppConnectivityObserver implements ConnectivityObserver {
  late final Connectivity _connectivity = Connectivity();

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  @override
  Future<ConnectivityResult> checkConnectivity() =>
      _connectivity.checkConnectivity();
}

@LazySingleton(as: ConnectivityObserver)
@test
class TestConnectivityObserver implements ConnectivityObserver {
  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      Stream.value(ConnectivityResult.wifi);

  @override
  Future<ConnectivityResult> checkConnectivity() =>
      Future.value(ConnectivityResult.wifi);
}

/// A use case which checks for connectivity.
/// If we have connection enabled, it simply returns the input and closes.
/// If we don't, it adds a [ConnectivityError] to the queue and
/// awaits until connection is enabled.
mixin ConnectivityUseCaseMixin<In, Out> on UseCase<In, Out> {
  @override
  Stream<In> transform(Stream<In> stream) async* {
    final ConnectivityObserver observer = di.get();

    Stream<In> Function(ConnectivityResult) mapper(In event) =>
        (ConnectivityResult it) {
          switch (it) {
            case ConnectivityResult.none:
              return Stream<In>.error(ConnectivityError(), StackTrace.current);
            default:
              return Stream.value(event);
          }
        };

    observeConnectivity() async* {
      yield await observer.checkConnectivity();
      yield* observer.onConnectivityChanged;
    }

    yield* stream.asyncExpand(
      (it) => observeConnectivity()
          .distinct()
          .takeWhileInclusive((it) => it == ConnectivityResult.none)
          .asyncExpand(mapper(it)),
    );
  }
}

class ConnectivityError extends Error {}
