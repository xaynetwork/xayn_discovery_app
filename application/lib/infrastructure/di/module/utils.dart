import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

@module
abstract class UtilsModule {
  @preResolve
  @lazySingleton
  @releaseEnvironment
  @debugEnvironment
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();

  @preResolve
  @lazySingleton
  @test
  Future<PackageInfo> get packageInfoTest => Future.value(
        PackageInfo(
          appName: '',
          buildNumber: '',
          packageName: '',
          version: '',
          buildSignature: '',
        ),
      );

  @preResolve
  @lazySingleton
  @test
  Future<Purchases> preparePurchasesTest() async => Purchases();

  @preResolve
  @lazySingleton
  @Environment(defaultEnvironmentName)
  Future<Purchases> preparePurchases() async {
    Purchases.setDebugLogsEnabled(!EnvironmentHelper.kIsProductionFlavor);
    await Purchases.setup(Env.revenueCatSdkKey);
    return Purchases();
  }
}
