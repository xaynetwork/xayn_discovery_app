import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/get_discovery_feed_scroll_direction_use_case.dart';

@injectable
class ListenDiscoveryFeedScrollDirectionUseCase
    extends UseCase<None, DiscoveryFeedScrollDirection> {
  final FakeDiscoveryFeedScrollDirectionStorage _storage;

  ListenDiscoveryFeedScrollDirectionUseCase(
    this._storage,
  );

  @factoryMethod
  static ListenDiscoveryFeedScrollDirectionUseCase create(
      FakeDiscoveryFeedScrollDirectionStorage storage) {
    return ListenDiscoveryFeedScrollDirectionUseCase(storage);
  }

  @override
  Stream<DiscoveryFeedScrollDirection> transaction(None param) =>
      _storage.asStream(() => _storage.value);
}
