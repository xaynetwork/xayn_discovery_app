import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';

@injectable
class ListenAppThemeUseCase extends UseCase<None, AppTheme> {
  late final _inner = DbEntityCrudUseCase(_repository);
  final HiveAppSettingsRepository _repository;

  ListenAppThemeUseCase(this._repository);

  @override
  Stream<AppTheme> transaction(None param) {
    return _inner
        .transaction(DbCrudIn.watch(AppSettings.globalId))
        .map((event) => event.mapOrNull(single: (s) => s.value?.appTheme))
        .whereType<AppTheme>()
        .distinct();
  }
}
