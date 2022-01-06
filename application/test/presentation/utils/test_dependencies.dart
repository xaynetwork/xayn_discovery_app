import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';

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
  packageInfoMock();
  configureDependencies();
  $initTestGetIt(di);
  // re-register as a sync singleton,
  // because this manager is required sync later on, as the navigation is also sync-based.
  di.registerSingleton<DiscoveryFeedManager>(
      await di.getAsync<DiscoveryFeedManager>());
}

void packageInfoMock() {
  TestDefaultBinaryMessengerBinding.instance?.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/package_info'),
          (MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        // 'appName': 'ABC',
        // 'packageName': 'A.B.C', // <--- set initial values here
        // 'version': '1.0.0', // <--- set initial values here
        // 'buildNumber': '' // <--- set initial values here
      };
    }
    return null;
  });
}
