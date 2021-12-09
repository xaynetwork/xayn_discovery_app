import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class ListenAppThemeUseCase extends UseCase<None, AppTheme> {
  final AppSettingsRepository _repository;

  ListenAppThemeUseCase(this._repository);

  @override
  Stream<AppTheme> transaction(None param) => _repository.watch().transform(
        StreamTransformer.fromHandlers(
          handleData:
              (RepositoryEvent<AppSettings> event, EventSink<AppTheme> sink) {
            if (event is ChangedEvent) {
              final theme =
                  (event as ChangedEvent<AppSettings>).newObject.appTheme;
              sink.add(theme);
            }
          },
        ),
      );
}
