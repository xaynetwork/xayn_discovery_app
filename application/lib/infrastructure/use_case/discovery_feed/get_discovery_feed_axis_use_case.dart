import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';

@injectable
class GetDiscoveryFeedAxisUseCase extends UseCase<None, DiscoveryFeedAxis> {
  final AppSettingsRepository _repository;

  GetDiscoveryFeedAxisUseCase(this._repository);

  @override
  Stream<DiscoveryFeedAxis> transaction(None param) async* {
    yield _repository.settings.discoveryFeedAxis;
  }
}
