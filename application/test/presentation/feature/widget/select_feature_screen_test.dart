import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

import '../../test_utils/utils.dart';
import '../../test_utils/widget_test_utils.dart';

void main() {
  late MockFeatureManager manager;
  setUp(() async {
    await setupWidgetTest();
    manager = MockFeatureManager();
    di.registerLazySingleton<FeatureManager>(() => manager);
    when(manager.isRatingDialogEnabled).thenReturn(true);
    when(manager.showFeaturesScreen).thenReturn(true);
    when(manager.showOnboardingScreen).thenReturn(false);
  });
  tearDown(() async {
    await tearDownWidgetTest();
  });

  testWidgets(
    'WHEN FeatureScreen dispose THEN manager.close not called',
    (final WidgetTester tester) async {
      await tester.initToFeatureSelectionPage();
      when(manager.isRatingDialogEnabled).thenReturn(true);
      when(manager.showFeaturesScreen).thenReturn(false);
      when(manager.showDiscoveryEngineReportOverlay).thenReturn(false);

      // we swap FeatureScreen with another one
      await tester.initToDiscoveryPage();
      verifyNever(manager.close());
    },
  );
}
