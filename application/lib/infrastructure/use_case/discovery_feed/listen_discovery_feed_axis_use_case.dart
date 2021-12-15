import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class ListenDiscoveryFeedAxisUseCase extends UseCase<None, DiscoveryFeedAxis> {
  final AppSettingsRepository _repository;

  ListenDiscoveryFeedAxisUseCase(this._repository);

  @override
  Stream<DiscoveryFeedAxis> transaction(None param) =>
      _repository.watch().transform(
        StreamTransformer.fromHandlers(
          handleData: (RepositoryEvent<AppSettings> event,
              EventSink<DiscoveryFeedAxis> sink) {
            if (event is ChangedEvent) {
              final axis = (event as ChangedEvent<AppSettings>)
                  .newObject
                  .discoveryFeedAxis;
              sink.add(axis);
            }
          },
        ),
      );
}
