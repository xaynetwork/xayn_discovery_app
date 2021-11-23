import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';

@injectable
class ListenAppThemeUseCase extends UseCase<void, AppTheme> {
  final FakeAppThemeStorage _storage;
  final StreamController<AppTheme> _controller;

  ListenAppThemeUseCase(
    this._storage,
    this._controller,
  );

  @factoryMethod
  static ListenAppThemeUseCase create(FakeAppThemeStorage storage) {
    final controller = StreamController<AppTheme>();
    return ListenAppThemeUseCase(storage, controller);
  }

  VoidCallback? _listener;

  @override
  Stream<AppTheme> transaction(void param) async* {
    if (_listener == null) {
      _listener = () {
        _controller.add(_storage.value);
      };
      _storage.addListener(_listener!);
      _controller.onCancel = () {
        _storage.removeListener(_listener!);
      };
    }

    yield* _controller.stream;
  }
}
