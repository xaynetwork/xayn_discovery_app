import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

abstract class AppLifecycleUseCase {
  Stream<bool> get onPauseStream;

  void updateOnPause(bool value);
}

@LazySingleton(as: AppLifecycleUseCase)
class AppLifecycleUseCaseImpl implements AppLifecycleUseCase {
  late final BehaviorSubject<bool> _pauseSubject;

  @visibleForTesting
  AppLifecycleUseCaseImpl({required bool initialPauseValue}) {
    _pauseSubject = BehaviorSubject<bool>.seeded(initialPauseValue);
  }

  @factoryMethod
  factory AppLifecycleUseCaseImpl.autowired() =>
      AppLifecycleUseCaseImpl(initialPauseValue: false);

  @override
  Stream<bool> get onPauseStream => _pauseSubject.stream.distinct();

  @override
  void updateOnPause(bool value) => _pauseSubject.add(value);
}
