import 'package:flutter_test/flutter_test.dart' hide test;
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';

import 'test_dependencies.config.dart';

/// Test dependencies that will allow to start the widget tree with fake implementations.
/// This allows to run widget tests or unit tests that contain complex setups.
/// The dependency order is as follows:
/// - allow override on di
/// - configure the default app dependencies
///   (careful with singletons, they will be initialized on creation,
///    it is preferred to use [LazySingleton] )
/// - then load the [$initTestGetIt] which is based on the [dependency_overrides.dart]
@InjectableInit(
    initializerName: r'$initTestGetIt',
    preferRelativeImports: true,
    asExtension: false,
    generateForDir: ['test'])
Future<void> configureTestDependencies() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.allowReassignment = true;
  await configureDependencies(environment: test.name);
  $initTestGetIt(di);
}
