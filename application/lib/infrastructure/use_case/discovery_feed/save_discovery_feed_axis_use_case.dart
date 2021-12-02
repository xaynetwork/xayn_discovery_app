import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class SaveDiscoveryFeedAxisUseCase
    extends UseCase<DiscoveryFeedAxis, DiscoveryFeedAxis> {
  final AppSettingsRepository _repository;

  SaveDiscoveryFeedAxisUseCase(this._repository);

  @override
  Stream<DiscoveryFeedAxis> transaction(DiscoveryFeedAxis param) async* {
    final settings = await _repository.getSettings();
    final updatedSettings = settings.copyWith(discoveryFeedAxis: param);
    await _repository.save(updatedSettings);
    yield param;
  }
}
