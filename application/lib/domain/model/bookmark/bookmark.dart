import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/infrastructure/util/uri_extensions.dart';

import '../unique_id.dart';

part 'bookmark.freezed.dart';

@freezed
class Bookmark extends DbEntity with _$Bookmark {
  @Assert('title.isNotEmpty', 'title cannot be empty')
  @Assert('createdAt.isNotEmpty', 'createdAt cannot be empty')
  factory Bookmark._({
    /// Will have the same value of documentId of the [Document] object
    required UniqueId id,
    required UniqueId collectionId,
    required Uint8List? image,
    required String title,
    required DocumentProvider? provider,
    required String url,

    /// To store as UTC value
    required String createdAt,
  }) = _Bookmark;

  factory Bookmark({
    /// Will have the same value of documentId of the [Document] object
    required UniqueId id,
    required UniqueId collectionId,
    required Uint8List? image,
    required String title,
    required DocumentProvider? provider,
    required Uri uri,

    /// To store as UTC value
    required String createdAt,
  }) =>
      Bookmark._(
        id: id,
        collectionId: collectionId,
        image: image,
        title: title,
        provider: provider,
        url: uri.removeQueryParameters.toString(),
        createdAt: createdAt,
      );
}
