import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class ListenDiscoveryFeedAxisUseCase extends UseCase<None, DiscoveryFeedAxis> {
  final AppSettingsRepository _repository;

  ListenDiscoveryFeedAxisUseCase(this._repository);

  @override
  Stream<DiscoveryFeedAxis> transaction(None param) async* {
    final controller = StreamController<DiscoveryFeedAxis>();
    _repository.watch().listen((_) async {
      final settings = await _repository.getSettings();
      controller.add(settings.discoveryFeedAxis);
    });
    yield* controller.stream;
  }
}
