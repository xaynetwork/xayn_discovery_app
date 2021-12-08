import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class ListenAppThemeUseCase extends UseCase<None, AppTheme> {
  final AppSettingsRepository _repository;

  ListenAppThemeUseCase(this._repository);

  @override
  Stream<AppTheme> transaction(None param) async* {
    final controller = StreamController<AppTheme>();
    _repository.watch().listen((_) async {
      final settings = await _repository.settings;
      controller.add(settings.appTheme);
    });
    yield* controller.stream;
  }
}
