import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@module
abstract class UtilsModule {
  @preResolve
  @lazySingleton
  @Environment('default')
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
