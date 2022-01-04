import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/navigation/navigator_delegate.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';

import 'di_config.config.dart';

/// Reference to the [GetIt] instance
/// refer to this object when needing programmatic dependency injection.
final di = GetIt.instance;

/// Boilerplate setup for DI.
@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
void configureDependencies() {
  $initGetIt(di);
  di.registerLazySingleton<RouteRegistration>(
      () => di.get<AppNavigationManager>());
}
