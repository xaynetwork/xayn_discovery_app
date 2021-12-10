import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';

import '../unique_id.dart';

part 'bookmark_two.freezed.dart';

@freezed
class BookmarkTwo extends DbEntity with _$BookmarkTwo {
  factory BookmarkTwo({
    required UniqueId id,
    required UniqueId collectionId,
    required String imageUri,
    required String title,
    required String providerName,
    required String providerThumbnail,
    required DateTime createdAt,
  }) = _BookmarkTwo;
}
