import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

@module
abstract class UtilsModule {
  @preResolve
  @lazySingleton
  @Environment(defaultEnvironmentName)
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

  Future<Purchases> getPurchases()async{

  }
}
