import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';

import '../unique_id.dart';

part 'bookmark.freezed.dart';

@freezed
class Bookmark extends DbEntity with _$Bookmark {
  @Assert('title.isNotEmpty', 'title cannot be empty')
  @Assert('providerName.isNotEmpty', 'providerName cannot be empty')
  @Assert('createdAt.isNotEmpty', 'createdAt cannot be empty')
  factory Bookmark({
    /// Will have the same value of documentId of the [Document] object
    required UniqueId id,
    required UniqueId collectionId,
    required Uint8List? image,
    required String title,
    required String? providerName,
    required Uint8List? providerThumbnail,

    /// To store as UTC value
    required String createdAt,
  }) = _Bookmark;
}
