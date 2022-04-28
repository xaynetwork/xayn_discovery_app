import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

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
  late final BehaviorSubject<ConnectivityResult> _onSubject =
      BehaviorSubject<ConnectivityResult>();
  late final String _host = Uri.parse(Env.searchApiBaseUrl).host;

  AppConnectivityObserver() {
    _connectivity.checkConnectivity().then((it) async {
      _onSubject.add(await _verifyConnectivity(it));
      _onSubject.addStream(
          _connectivity.onConnectivityChanged.asyncMap(_verifyConnectivity));
    });
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged => _onSubject.stream;

  @override
  Future<ConnectivityResult> checkConnectivity() =>
      _connectivity.checkConnectivity();

  /// [ConnectivityResult] can sometimes be a false positive/negative
  /// Therefore, we do an IP ping to verify if the value is correct.
  Future<ConnectivityResult> _verifyConnectivity(
      ConnectivityResult value) async {
    try {
      // this is required, as the connectivity event seems to be emitted too soon sometimes
      // the delay adds some time to await the effects
      await Future.delayed(const Duration(milliseconds: 100));

      final result = await InternetAddress.lookup(_host);

      // rewrites a false negative if needed
      maybeOverrideValueWhenUp(ConnectivityResult value) =>
          value == ConnectivityResult.none ? ConnectivityResult.wifi : value;

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty
          ? maybeOverrideValueWhenUp(value)
          : ConnectivityResult.none;
    } on SocketException catch (_) {
      return ConnectivityResult.none;
    }
  }
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
