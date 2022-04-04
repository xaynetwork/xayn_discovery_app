import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

abstract class AppLifecycleUseCase {
  Stream<bool> get pauseStream;

  void updateOnPause(bool onPause);
}

@LazySingleton(as: AppLifecycleUseCase)
class AppLifecycleUseCaseImpl implements AppLifecycleUseCase {
  late final BehaviorSubject<bool> _pauseSubject = BehaviorSubject<bool>();

  @visibleForTesting
  AppLifecycleUseCaseImpl({required bool initialPauseValue}) {
    _pauseSubject.add(initialPauseValue);
  }

  @factoryMethod
  AppLifecycleUseCaseImpl.autowired() {
    _pauseSubject.add(false);
  }

  @override
  Stream<bool> get pauseStream => _pauseSubject.stream;

  @override
  void updateOnPause(bool onPause) => _pauseSubject.add(onPause);
}
