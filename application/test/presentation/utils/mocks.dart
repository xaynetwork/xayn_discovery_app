import 'package:mockito/annotations.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/app_session/save_app_session_use_case.dart';
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
  SettingsScreenManager,
  IncrementAppSessionUseCase,
])
class Mocks {
  Mocks._();
}
