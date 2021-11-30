import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/get_discovery_feed_scroll_direction_use_case.dart';

@injectable
class SaveDiscoveryFeedScrollDirectionCase
    extends UseCase<DiscoveryFeedScrollDirection, None> {
  final FakeDiscoveryFeedScrollDirectionStorage _storage;

  SaveDiscoveryFeedScrollDirectionCase(this._storage);

  @override
  Stream<None> transaction(DiscoveryFeedScrollDirection param) async* {
    await Future.delayed(const Duration(milliseconds: 42));
    _storage.value = param;
    yield none;
  }
}
