import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';

const _gitTagEnv = String.fromEnvironment('GIT_TAG');

@lazySingleton
class GetAppVersionUseCase extends UseCase<void, AppVersion> {
  final PackageInfo _info;
  AppVersion? _appVersion;

  GetAppVersionUseCase(
    this._info,
  );

  @override
  Stream<AppVersion> transaction(void param) async* {
    _appVersion ??= AppVersion(
      version: _getVersion(),
      build: _info.buildNumber,
    );
    yield _appVersion!;
  }

  String _getVersion() => _gitTagEnv.isNotEmpty ? _gitTagEnv : _info.version;
}
