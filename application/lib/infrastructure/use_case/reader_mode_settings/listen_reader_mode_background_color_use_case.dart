import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';

@injectable
class ListenReaderModeBackgroundColorUseCase
    extends UseCase<None, ReaderModeBackgroundColor> {
  final ReaderModeSettingsRepository _repository;

  ListenReaderModeBackgroundColorUseCase(this._repository);

  @override
  Stream<ReaderModeBackgroundColor> transaction(None param) => _repository
      .watch()
      .where((event) => event is ChangedEvent)
      .map((event) =>
          (event as ChangedEvent<ReaderModeSettings>).newObject.backgroundColor)
      .distinct();
}
