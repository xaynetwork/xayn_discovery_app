import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';

/// Repository interface for storing settings, related to the [FeedSettingsScreen]
abstract class FeedSettingsRepository {
  /// The [FeedSettings] setter method.
  void save(FeedSettings settings);

  /// The [FeedSettings] getter method.
  FeedSettings get settings;

  /// A stream of [FeedSettings].
  /// Emits when [FeedSettings] changes.
  Stream<RepositoryEvent<FeedSettings>> watch();
}
