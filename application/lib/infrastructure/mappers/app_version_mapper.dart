import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _version = 0;
const int _build = 1;

@singleton
class MapToAppVersionMapper implements Mapper<Map?, AppVersion?> {
  const MapToAppVersionMapper();

  @override
  AppVersion? map(Map? input) {
    if (input == null || input is! Map<int, dynamic>) return null;

    final version = input[_version] as String?;
    final build = input[_build] as String?;
    if (version == null || build == null) return null;

    return AppVersion(
      version: version,
      build: build,
    );
  }
}

@singleton
class AppVersionToMapMapper implements Mapper<AppVersion?, Map?> {
  const AppVersionToMapMapper();

  @override
  Map? map(AppVersion? input) {
    if (input == null) return null;

    return {
      _version: input.version,
      _build: input.build,
    };
  }
}
