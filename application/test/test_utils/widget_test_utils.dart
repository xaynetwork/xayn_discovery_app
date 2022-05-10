import 'package:flutter/src/semantics/debug.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';
import 'package:xayn_discovery_app/main.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

import '../test_utils/utils.dart';

/// common setup for widget tests
Future<void> setupWidgetTest() async {
  debugSemanticsDisableAnimations = true;
  HiveDB.init(null);
  await configureTestDependencies();
}

/// common teardown for widget tests
Future<void> tearDownWidgetTest() async {
  await Hive.close();
  await di.reset();
}

extension WidgetTesterCommonActions on WidgetTester {
  Future<void> initToFeatureSelectionPage() async {
    await pumpAndSettle();
    di.get<FeatureManager>().overrideFeature(Feature.featuresScreen, true);
    await pumpWidget(getApp());
  }

  Future<void> initToDiscoveryPage() async {
    await pumpAndSettle();
    di.get<FeatureManager>().overrideFeature(Feature.featuresScreen, false);
    await pumpWidget(getApp());
    await pumpAndSettle();
  }

  Future<void> navigateToSearch() async {
    await pumpAndSettle();
    await tap(Keys.navBarItemSearch.finds());
    await pumpAndSettle();
  }

  Future<void> navigateToHome() async {
    await pumpAndSettle();
    await tap(Keys.navBarItemHome.finds());
    await pumpAndSettle();
  }

  Future<void> navigateToPersonalArea() async {
    await pumpAndSettle();
    await tap(Keys.navBarItemPersonalArea.finds());
    await pumpAndSettle();
  }

  Future<void> navigateToSettingsScreen() async {
    await pumpAndSettle();
    final settingsIcon = Keys.personalAreaIconSettings.finds();
    await tap(settingsIcon);
    await pumpAndSettle();
  }

  Future<void> navigateBack() async {
    await pumpAndSettle();
    await tap(Keys.navBarItemBackBtnBase.finds());
    await pumpAndSettle();
  }
}
