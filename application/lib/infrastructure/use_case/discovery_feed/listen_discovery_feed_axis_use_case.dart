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

  // @factoryMethod
  // static ListenDiscoveryFeedAxisUseCase create(
  //     FakeDiscoveryFeedAxisStorage storage) {
  //   return ListenDiscoveryFeedAxisUseCase(storage);
  // }

  // @override
  // Stream<DiscoveryFeedAxis> transaction(None param) =>
  //     _storage.asStream(() => _storage.value);

  @override
  Stream<DiscoveryFeedAxis> transaction(None param) =>
      Stream.value(DiscoveryFeedAxis.horizontal);
}
