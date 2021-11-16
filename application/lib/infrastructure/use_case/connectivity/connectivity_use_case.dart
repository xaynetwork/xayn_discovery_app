import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
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
    final startingValue = await connectivity.checkConnectivity();

    mapper(ConnectivityResult it) {
      switch (it) {
        case ConnectivityResult.none:
          return Stream<T>.error(ConnectivityError(), StackTrace.current);
        default:
          return Stream.value(param);
      }
    }

    yield* connectivity.onConnectivityChanged
        .startWith(startingValue)
        .distinct()
        .switchMap(mapper)
        .take(1);
  }
}

@injectable
class ConnectivityUriUseCase extends ConnectivityUseCase<Uri> {
  ConnectivityUriUseCase();
}

class ConnectivityError extends Error {}
