import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';

@GenerateMocks([
  AppManager,
  FeatureManager,
  Document,
  GetAppThemeUseCase,
  ListenAppThemeUseCase,
  SettingsNavActions,
  PersonalAreaNavActions,
  SettingsScreenManager,
  ActiveSearchNavActions,
  PersonalAreaManager,
  DiscoveryEngine,
])
class Mocks {
  Mocks._();
}
