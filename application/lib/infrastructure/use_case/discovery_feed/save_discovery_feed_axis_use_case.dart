import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/get_discovery_feed_axis_use_case.dart';

@injectable
class SaveDiscoveryFeedAxisUseCase extends UseCase<DiscoveryFeedAxis, None> {
  final FakeDiscoveryFeedAxisStorage _storage;

  SaveDiscoveryFeedAxisUseCase(this._storage);

  @override
  Stream<None> transaction(DiscoveryFeedAxis param) async* {
    await Future.delayed(const Duration(milliseconds: 42));
    _storage.value = param;
    yield none;
  }
}
