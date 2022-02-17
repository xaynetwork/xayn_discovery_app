import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/domain/repository/feed_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [AppSettings] repository implementation.
@Singleton(as: FeedRepository)
class HiveFeedRepository extends HiveRepository<Feed>
    implements FeedRepository {
  final FeedMapper _mapper;
  Box<Record>? _box;

  HiveFeedRepository(this._mapper);

  @visibleForTesting
  HiveFeedRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<Feed> get mapper => _mapper;

  @override
  Box<Record> get box => _box ??= Hive.box<Record>(BoxNames.feed);

  @override
  Feed get() => getById(Feed.globalId) ?? Feed.initial();
}
