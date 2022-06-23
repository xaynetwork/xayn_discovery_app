import 'dart:typed_data';

import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/crud_entity_repository.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

// ignore: camel_case_types
class Migration_3_To_4 extends BaseDbMigration {
  @override
  Migration_3_To_4();

  @override
  Future<int> rollbackMigration(int fromVersion) async {
    return fromVersion;
  }

  @override
  Future<int> runMigration(int fromVersion) async {
    assert(fromVersion == 3);

    final documentBoxRepository = CrudEntityRepository<DocumentWrapper>(
      box: 'documents',
      toMap: documentWrapperToMap,
      fromMap: documentWrapperFromMap,
    );
    final bookmarkBoxRepository = CrudEntityRepository<Bookmark>(
      box: 'bookmarks',
      fromMap: bookmarkFromMap,
      toMap: bookmarkToMap,
    );

    /// Get the current bookmarks list
    final bookmarks = bookmarkBoxRepository.getAll();

    final newBookmarks = <UniqueId, Bookmark>{};

    /// For each bookmark, get the url from the stored documents and generate a unique id out of it
    for (var bookmark in bookmarks) {
      if (bookmark == null) continue;

      final document = documentBoxRepository.getById(bookmark.id);

      if (document == null) continue;

      final bookmarkId = document.document.toBookmarkId;
      final newBookmark = bookmark.copyWith(
        id: bookmarkId,
        documentId: document.document.documentUniqueId,
      );

      newBookmarks.addAll({bookmarkId: newBookmark});
    }

    bookmarkBoxRepository.deleteValues(bookmarks);

    bookmarkBoxRepository.saveValues(newBookmarks.values.toList());

    return 4;
  }
}

DocumentWrapper? documentWrapperFromMap(Map? map) {
  if (map == null) return null;

  final json =
      map[DocumentBookmarkMapperFieldsMigration.json] as Map<dynamic, dynamic>;

  return DocumentWrapper(Document.fromJson(json.cast()));
}

DbEntityMap documentWrapperToMap(DocumentWrapper entity) => {
      DocumentBookmarkMapperFieldsMigration.id: entity.id.value,
      DocumentBookmarkMapperFieldsMigration.json: entity.document.toJson(),
    };

Bookmark? bookmarkFromMap(Map? map) {
  if (map == null) return null;

  final id =
      map[BookmarkMapperFieldsMigration.id] ?? throwMapperException() as String;

  final collectionId = map[BookmarkMapperFieldsMigration.collectionId] ??
      throwMapperException() as String;

  final documentId = map[BookmarkMapperFieldsMigration.documentId] ??
      throwMapperException() as String;

  final title = map[BookmarkMapperFieldsMigration.title] ??
      throwMapperException() as String;

  /// The [image] field is nullable
  final image = map[BookmarkMapperFieldsMigration.image] as Uint8List?;

  /// The [providerName] field is nullable
  final providerName = map[BookmarkMapperFieldsMigration.providerName];

  /// The [favicon] field is nullable
  final favicon =
      map[BookmarkMapperFieldsMigration.providerThumbnail] as String?;

  final createdAt = map[BookmarkMapperFieldsMigration.createdAt] ??
      throwMapperException() as String;

  return Bookmark.fromMap(
    id: UniqueId.fromTrustedString(id),
    documentId: UniqueId.fromTrustedString(documentId),
    collectionId: UniqueId.fromTrustedString(collectionId),
    title: title,
    image: image,
    provider: DocumentProvider(
      name: providerName,
      favicon: favicon,
    ),
    createdAt: createdAt,
  );
}

DbEntityMap bookmarkToMap(Bookmark entity) => {
      BookmarkMapperFieldsMigration.id: entity.id.value,
      BookmarkMapperFieldsMigration.collectionId: entity.collectionId.value,
      BookmarkMapperFieldsMigration.title: entity.title,
      BookmarkMapperFieldsMigration.image: entity.image,
      BookmarkMapperFieldsMigration.providerName: entity.provider?.name,
      BookmarkMapperFieldsMigration.providerThumbnail: entity.provider?.favicon,
      BookmarkMapperFieldsMigration.createdAt: entity.createdAt,
      BookmarkMapperFieldsMigration.documentId: entity.documentId.value,
    };

void throwMapperException([
  String exceptionText =
      'error occurred while mapping the object during migration',
]) =>
    throw DbEntityMapperException(exceptionText);

abstract class DocumentBookmarkMapperFieldsMigration {
  const DocumentBookmarkMapperFieldsMigration._();

  static const int id = 0;
  static const int json = 1;
}

abstract class BookmarkMapperFieldsMigration {
  const BookmarkMapperFieldsMigration._();

  static const int id = 0;
  static const int collectionId = 1;
  static const int title = 2;
  static const int image = 3;
  static const int providerName = 4;
  static const int providerThumbnail = 5;
  static const int createdAt = 6;
  static const int documentId = 7;
}
