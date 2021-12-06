import 'package:equatable/equatable.dart';

class MigrationInfo extends Equatable {
  /// Increment this version for each change on the DB structure, new fields etc and
  /// write a migration
  static const int dbVersion = 0;

  // can be null
  final int version;

  const MigrationInfo({required this.version});

  @override
  List<Object> get props => [version];
}
