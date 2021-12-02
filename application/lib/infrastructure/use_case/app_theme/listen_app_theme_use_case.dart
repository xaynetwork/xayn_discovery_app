import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class ListenAppThemeUseCase extends UseCase<None, AppTheme> {
  final AppSettingsRepository _repository;

  ListenAppThemeUseCase(this._repository);

  // @factoryMethod
  // static ListenAppThemeUseCase create(FakeAppThemeStorage storage) {
  //   return ListenAppThemeUseCase(storage);
  // }

  // @override
  // Stream<AppTheme> transaction(None param) =>
  //     _storage.asStream(() => _storage.value);

  @override
  Stream<AppTheme> transaction(None param) => Stream.value(AppTheme.system);
}
