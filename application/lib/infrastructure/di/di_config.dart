import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/navigation/navigator_delegate.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';

import 'di_config.config.dart';

/// Reference to the [GetIt] instance
/// refer to this object when needing programmatic dependency injection.
final di = GetIt.instance;

const String defaultEnvironmentName = 'defaultEnvironment';

/// Acts as a "joint" environment for dev and prod
/// When required, use [Environment.test] to create test specific DI,
/// and use [defaultEnvironment] to create an equivalent for dev/prod.
const Environment defaultEnvironment = Environment(defaultEnvironmentName);

/// Boilerplate setup for DI.
@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies({
  Environment environment = defaultEnvironment,
}) async {
  await $initGetIt(
    di,
    environment: environment.name,
  );
  di.registerLazySingleton<RouteRegistration>(
      () => di.get<AppNavigationManager>());
}
