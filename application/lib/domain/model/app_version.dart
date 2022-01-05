import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:xayn_discovery_app/infrastructure/util/package_version_extensions.dart';

@immutable
class AppVersion {
  final String version;
  final String build;

  String get _comparableValue => '$version+$build';

  const AppVersion({
    required this.version,
    required this.build,
  });

  factory AppVersion.initial() =>
      const AppVersion(version: '0.0.1', build: '0.0.1');

  factory AppVersion.current(PackageInfo info) => AppVersion(
        version: info.formattedVersion,
        build: info.buildNumber,
      );

  @override
  String toString() => 'Version: $version, build: $build';

  @override
  int get hashCode => toString().hashCode;

  bool operator >(dynamic other) =>
      other is AppVersion &&
      Version.parse(_comparableValue) > Version.parse(other._comparableValue);

  bool operator >=(dynamic other) =>
      other is AppVersion &&
      Version.parse(_comparableValue) >= Version.parse(other._comparableValue);

  bool operator <(dynamic other) =>
      other is AppVersion &&
      Version.parse(_comparableValue) < Version.parse(other._comparableValue);

  bool operator <=(dynamic other) =>
      other is AppVersion &&
      Version.parse(_comparableValue) <= Version.parse(other._comparableValue);

  @override
  bool operator ==(dynamic other) =>
      other is AppVersion &&
      Version.parse(_comparableValue) == Version.parse(other._comparableValue);
}
