import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';

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
}
