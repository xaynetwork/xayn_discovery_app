import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class GetAppThemeUseCase extends UseCase<None, AppTheme> {
  final AppSettingsRepository _repository;

  GetAppThemeUseCase(this._repository);

  @override
  Stream<AppTheme> transaction(None param) async* {
    final settings = await _repository.getSettings();
    yield settings.appTheme;
  }
}
