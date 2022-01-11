import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';

import '../../test_utils/utils.dart';
import '../../test_utils/widget_test_utils.dart';

void main() {
  late MockAppManager manager;
  setUp(() async {
    await setupWidgetTest();
    manager = MockAppManager();
    di.registerLazySingleton<AppManager>(() => manager);
    when(manager.state).thenReturn(AppState.empty());
    when(manager.stream).thenAnswer((_) => const Stream.empty());
  });
  tearDown(() async {
    await tearDownWidgetTest();
  });

  testWidgets(
    'WHEN App dispose THEN manager.close not called',
    (final WidgetTester tester) async {
      await tester.initToDiscoveryPage();

      // we swap App with another one widget
      await tester.pumpWidget(const Center());
      verifyNever(manager.close());
    },
  );
}
