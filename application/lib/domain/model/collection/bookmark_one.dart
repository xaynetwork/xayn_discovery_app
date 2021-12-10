import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';

import '../unique_id.dart';

part 'bookmark_one.freezed.dart';

@freezed
class BookmarkOne extends DbEntity with _$BookmarkOne {
  factory BookmarkOne({
    required UniqueId id,
    required UniqueId collectionId,
    required WebResource webResource,
    required DateTime createdAt,
  }) = _BookmarkOne;
}
