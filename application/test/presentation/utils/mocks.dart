import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/get_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/get_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_theme/listen_app_theme_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/get_stored_app_version_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_version/save_app_version_use_case.dart';
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
  SettingsScreenManager,
  ActiveSearchNavActions,
  DiscoveryEngine,
  IncrementAppSessionUseCase,
  MapToAppVersionMapper,
  AppVersionToMapMapper,
  GetAppVersionUseCase,
  GetStoredAppVersionUseCase,
  SaveCurrentAppVersion,
  GetAppSessionUseCase,
  InAppReview,
])
class Mocks {
  Mocks._();
}
