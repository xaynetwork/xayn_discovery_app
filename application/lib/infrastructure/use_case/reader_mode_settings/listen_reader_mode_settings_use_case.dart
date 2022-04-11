import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';

@injectable
class ListenReaderModeSettingsUseCase
    extends UseCase<None, ReaderModeSettings> {
  final ReaderModeSettingsRepository _repository;

  ListenReaderModeSettingsUseCase(this._repository);

  @override
  Stream<ReaderModeSettings> transaction(None param) async* {
    yield _repository.settings;

    yield* _repository.watch().transform(
      StreamTransformer.fromHandlers(
        handleData: (RepositoryEvent<ReaderModeSettings> event,
            EventSink<ReaderModeSettings> sink) {
          if (event is ChangedEvent) {
            final settings =
                (event as ChangedEvent<ReaderModeSettings>).newObject;
            sink.add(settings);
          }
        },
      ),
    );
  }
}
