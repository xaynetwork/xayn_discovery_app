import 'package:flutter/src/semantics/debug.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:xayn_design/src/widget/nav_bar/widget/nav_bar_container.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_engine_results_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/bing_request_builder_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';
import 'package:xayn_discovery_app/main.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

import '../utils/utils.dart';

/// common setup for widget tests
void setupWidgetTest() {
  debugSemanticsDisableAnimations = true;
  HiveDB.init(null);
  configureTestDependencies();
}

/// common teardown for widget tests
Future<void> tearDownWidgetTest() async {
  await Hive.close();
  await di.reset();
}

extension WidgetTesterCommonActions on WidgetTester {
  Future<void> initToFeatureSelectionPage() async {
    di.get<FeatureManager>().overrideFeature(Feature.featuresScreen, true);
    await pumpWidget(getApp());
  }

  Future<void> initToDiscoveryPage() async {
    di.get<FeatureManager>().overrideFeature(Feature.featuresScreen, false);
    await pumpWidget(getApp());
    await pumpAndSettle(kScrollUpdateUseCaseDebounceTime +
        kDebounceDuration +
        updateNabBarDebounceTimeout);
  }

  Future<void> navigateToSearch() async {
    await tap(Keys.navBarItemSearch.finds());
    await pumpAndSettle();
  }

  Future<void> navigateToHome() async {
    await tap(Keys.navBarItemHome.finds());
    await pumpAndSettle();
  }

  Future<void> navigateToAccount() async {
    await tap(Keys.navBarItemAccount.finds());
    await pumpAndSettle();
  }

  Future<void> navigateToSettingsScreen() async {
    await tap(Keys.navBarItemAccount.finds());
    await pumpAndSettle();
  }

  Future<void> navigateBack() async {
    await tap(Keys.navBarItemBackBtn.finds());
    await pumpAndSettle();
  }
}
