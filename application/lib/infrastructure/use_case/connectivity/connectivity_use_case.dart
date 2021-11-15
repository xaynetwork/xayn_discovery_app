import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';

/// A use case which checks for connectivity.
/// If we have connection enabled, it simply returns the input and closes.
/// If we don't, it adds a [ConnectivityError] to the queue and
/// awaits until connection is enabled.
class ConnectivityUseCase<T> extends UseCase<T, T> {
  final Connectivity connectivity = Connectivity();

  ConnectivityUseCase();

  @override
  Stream<T> transaction(T param) async* {
    yield* connectivity.onConnectivityChanged.distinct().switchMap((it) {
      switch (it) {
        case ConnectivityResult.none:
          return Stream<T>.error(ConnectivityError(), StackTrace.current);
        default:
          return Stream.value(param);
      }
    }).take(1);
  }
}

class ConnectivityError extends Error {}
