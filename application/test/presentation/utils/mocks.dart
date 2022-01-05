import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@GenerateMocks([
  Document,
  ActiveSearchNavActions,
  DiscoveryEngine,
])
class Mocks {
  Mocks._();
}
