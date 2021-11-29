import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';

@injectable
class ListenAppThemeUseCase extends UseCase<None, AppTheme> {
  final FakeAppThemeStorage _storage;

  ListenAppThemeUseCase(
    this._storage,
  );

  @factoryMethod
  static ListenAppThemeUseCase create(FakeAppThemeStorage storage) {
    return ListenAppThemeUseCase(storage);
  }

  @override
  Stream<AppTheme> transaction(None param) =>
      _storage.asStream(() => _storage.value);
}
