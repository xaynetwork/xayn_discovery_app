import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/repository/feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_type_markets_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [FeedTypeMarketsRepository] repository implementation.
@Singleton(as: FeedTypeMarketsRepository)
class HiveFeedTypeMarketsRepository extends HiveRepository<FeedTypeMarkets>
    implements FeedTypeMarketsRepository {
  final FeedTypeMarketsMapper _mapper;
  Box<Record>? _box;

  HiveFeedTypeMarketsRepository(this._mapper);

  @visibleForTesting
  HiveFeedTypeMarketsRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<FeedTypeMarkets> get mapper => _mapper;

  @override
  Box<Record> get box =>
      _box ??= Hive.safeBox<Record>(BoxNames.feedTypeMarkets);

  @override
  FeedTypeMarkets get feed =>
      getById(FeedTypeMarkets.feedId) ??
      FeedTypeMarkets(
        id: FeedTypeMarkets.feedId,
        feedType: FeedType.feed,
        feedMarkets: const {},
      );

  @override
  FeedTypeMarkets get search =>
      getById(FeedTypeMarkets.searchId) ??
      FeedTypeMarkets(
        id: FeedTypeMarkets.searchId,
        feedType: FeedType.search,
        feedMarkets: const {},
      );
}
