import 'package:package_info_plus/package_info_plus.dart';

const _gitTagEnv = String.fromEnvironment('GIT_TAG');

extension PackageInfoExtension on PackageInfo {
  String get formattedVersion => _gitTagEnv.isNotEmpty ? _gitTagEnv : version;
}
