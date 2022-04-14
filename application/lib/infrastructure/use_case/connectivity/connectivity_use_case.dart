import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';

abstract class ConnectivityObserver {
  Stream<ConnectivityResult> get onConnectivityChanged;

  Future<ConnectivityResult> checkConnectivity();

  Future<ConnectivityResult> isUp() =>
      onConnectivityChanged.firstWhere((it) => it != ConnectivityResult.none);
}

@LazySingleton(as: ConnectivityObserver)
@releaseEnvironment
@debugEnvironment
class AppConnectivityObserver extends ConnectivityObserver {
  late final Connectivity _connectivity = Connectivity();

  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      Stream.fromFuture(_connectivity.checkConnectivity())
          .asyncExpand((_) => _connectivity.onConnectivityChanged)
          .distinct();

  @override
  Future<ConnectivityResult> checkConnectivity() =>
      _connectivity.checkConnectivity();
}

@LazySingleton(as: ConnectivityObserver)
@test
class TestConnectivityObserver extends ConnectivityObserver {
  @override
  Stream<ConnectivityResult> get onConnectivityChanged =>
      Stream.value(ConnectivityResult.wifi);

  @override
  Future<ConnectivityResult> checkConnectivity() =>
      Future.value(ConnectivityResult.wifi);
}
