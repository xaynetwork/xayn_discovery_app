import 'package:flutter/cupertino.dart';

@immutable
class AppVersion {
  final String version;
  final String build;

  const AppVersion({
    required this.version,
    required this.build,
  });

  @override
  String toString() => 'Version: $version, build: $build';
}
