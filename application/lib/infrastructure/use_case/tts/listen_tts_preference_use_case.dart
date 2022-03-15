import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class ListenTtsPreferenceUseCase extends UseCase<None, bool> {
  final AppSettingsRepository _repository;

  ListenTtsPreferenceUseCase(this._repository);

  @override
  Stream<bool> transaction(None param) => _repository.watch().transform(
        StreamTransformer.fromHandlers(
          handleData:
              (RepositoryEvent<AppSettings> event, EventSink<bool> sink) {
            if (event is ChangedEvent) {
              final autoPlayTextToSpeech = (event as ChangedEvent<AppSettings>)
                  .newObject
                  .autoPlayTextToSpeech;
              sink.add(autoPlayTextToSpeech);
            }
          },
        ),
      );
}
