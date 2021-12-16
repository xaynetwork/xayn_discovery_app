import 'dart:typed_data';

import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

class BookmarkMapper extends BaseDbEntityMapper<Bookmark> {
  @override
  Bookmark? fromMap(Map? map) {
    if (map == null) return null;

    final id = map[BookmarkMapperFields.id] ?? throwMapperException() as String;

    final collectionId = map[BookmarkMapperFields.collectionId] ??
        throwMapperException() as String;

    final title =
        map[BookmarkMapperFields.title] ?? throwMapperException() as String;

    final image =
        map[BookmarkMapperFields.image] ?? throwMapperException() as Uint8List;

    final providerName = map[BookmarkMapperFields.providerName] ??
        throwMapperException() as String;

    final providerThumbnail = map[BookmarkMapperFields.providerThumbnail] ??
        throwMapperException() as Uint8List;

    final createdAt =
        map[BookmarkMapperFields.createdAt] ?? throwMapperException() as String;

    return Bookmark(
      id: UniqueId.fromTrustedString(id),
      collectionId: UniqueId.fromTrustedString(collectionId),
      title: title,
      image: image,
      providerName: providerName,
      providerThumbnail: providerThumbnail,
      createdAt: createdAt,
    );
  }

  @override
  DbEntityMap toMap(Bookmark entity) => {
        BookmarkMapperFields.id: entity.id.value,
        BookmarkMapperFields.collectionId: entity.collectionId.value,
        BookmarkMapperFields.title: entity.title,
        BookmarkMapperFields.image: entity.image,
        BookmarkMapperFields.providerName: entity.providerName,
        BookmarkMapperFields.providerThumbnail: entity.providerThumbnail,
        BookmarkMapperFields.createdAt: entity.createdAt,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'BookmarkMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class BookmarkMapperFields {
  const BookmarkMapperFields._();

  static const int id = 0;
  static const int collectionId = 1;
  static const int title = 2;
  static const int image = 3;
  static const int providerName = 4;
  static const int providerThumbnail = 5;
  static const int createdAt = 6;
}
