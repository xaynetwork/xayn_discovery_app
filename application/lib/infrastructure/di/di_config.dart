import 'package:dart_remote_config/model/dart_remote_config_state.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:platform/platform.dart' as google;
import 'package:xayn_architecture/concepts/navigation/navigator_delegate.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/log_manager.dart';

import 'di_config.config.dart';

/// Reference to the [GetIt] instance
/// refer to this object when needing programmatic dependency injection.
final di = GetIt.instance;

const String releaseEnvironmentName = 'releaseEnvironment';

const String debugEnvironmentName = 'debugEnvironment';

/// Acts as a "joint" environment for dev and prod
/// When required, use [Environment.test] to create test specific DI,
/// and use [defaultEnvironment] to create an equivalent for dev/prod.
const Environment releaseEnvironment = Environment(releaseEnvironmentName);

/// Environment for debug mode only
const Environment debugEnvironment = Environment(debugEnvironmentName);

const Environment testEnvironment = Environment(Environment.test);

/// Boilerplate setup for DI.
@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies({
  Environment environment = releaseEnvironment,
}) async {
  await $initGetIt(
    di,
    environment: environment.name,
  );
  di.registerLazySingleton<RouteRegistration>(
      () => di.get<AppNavigationManager>());
  di.registerLazySingleton<AppSettingsRepository>(
      () => di.get<HiveAppSettingsRepository>());
  di.registerFactory<google.Platform>(() => const google.LocalPlatform());
}

void initServices() async {
  di.get<LogManager>();
}
