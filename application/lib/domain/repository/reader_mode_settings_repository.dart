import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';

/// Repository interface for storing reader mode settings.
abstract class ReaderModeSettingsRepository {
  /// The [ReaderModeSettings] setter method.
  void save(ReaderModeSettings readerModeSettings);

  /// The [ReaderModeSettings] getter method.
  ReaderModeSettings get settings;

  /// A stream of [RepositoryEvent]. Emits when [ReaderModeSettings] changes.
  Stream<RepositoryEvent<ReaderModeSettings>> watch();
}
