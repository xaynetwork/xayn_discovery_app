import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/user_interactions_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [UserInteractions] repository implementation.
@LazySingleton(as: UserInteractionsRepository)
class HiveUserInteractionsRepository extends HiveRepository<UserInteractions>
    implements UserInteractionsRepository {
  final UserInteractionsMapper _mapper;
  Box<Record>? _box;

  HiveUserInteractionsRepository(this._mapper);

  @visibleForTesting
  HiveUserInteractionsRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<UserInteractions> get mapper => _mapper;

  @override
  Box<Record> get box =>
      _box ??= Hive.safeBox<Record>(BoxNames.userInteractions);

  @override
  UserInteractions get userInteractions => getById(UserInteractions.globalId)!;

  @override
  UserInteractions? getById(UniqueId id) {
    return super.getById(id) ??
        (id == UserInteractions.globalId ? UserInteractions.initial() : null);
  }
}
