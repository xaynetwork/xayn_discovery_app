import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';

@lazySingleton
class GetAppVersionUseCase extends UseCase<None, AppVersion> {
  final PackageInfo _info;
  AppVersion? _appVersion;

  GetAppVersionUseCase(
    this._info,
  );

  @override
  Stream<AppVersion> transaction(None param) async* {
    _appVersion ??= AppVersion.current(_info);
    yield _appVersion!;
  }
}
