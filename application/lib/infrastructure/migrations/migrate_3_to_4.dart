import 'dart:typed_data';

import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/bookmark_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/crud_entity_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/uri_extensions.dart';
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

    final List<Bookmark> bookmarksWithUrlUpdated = [];
    final List<Bookmark> bookmarksToRemove = [];
    final List<Bookmark> bookmarksToSave = [];

    /// Get the current bookmarks list
    final bookmarks = bookmarkBoxRepository.getAll();

    /// For each bookmark, get the url from the stored documents
    for (var bookmark in bookmarks) {
      final document = documentBoxRepository.getById(bookmark!.id);

      bookmarksWithUrlUpdated.add(
        bookmark.copyWith(
          url: document!.document.resource.url.removeQueryParameters.toString(),
        ),
      );
    }

    /// Create two list of bookmarks:
    /// bookmarksToSave: list of the bookmarks that need to be update in the db
    /// bookmarksToRemove: list of the bookmarks that need to be removed, since they were duplicates
    for (var ub in bookmarksWithUrlUpdated) {
      if (bookmarksToSave.indexWhere((element) => element.url == ub.url) ==
          -1) {
        bookmarksToSave.add(ub);
      } else {
        bookmarksToRemove.add(ub);
      }
    }

    bookmarkBoxRepository.deleteValues(bookmarksToRemove);

    bookmarkBoxRepository.saveValues(bookmarksToSave);

    return 4;
  }
}

DocumentWrapper documentWrapperFromMap(Map map) {
  final json = map[DocumentBookmarkMapperFields.json] as Map<dynamic, dynamic>;

  return DocumentWrapper(Document.fromJson(json.cast()));
}

DbEntityMap documentWrapperToMap(DocumentWrapper entity) => {
      DocumentBookmarkMapperFields.id: entity.id.value,
      DocumentBookmarkMapperFields.json: entity.document.toJson(),
    };

Bookmark bookmarkFromMap(map) {
  final id = map[BookmarkMapperFields.id] ?? throwMapperException() as String;

  final collectionId = map[BookmarkMapperFields.collectionId] ??
      throwMapperException() as String;

  final title =
      map[BookmarkMapperFields.title] ?? throwMapperException() as String;

  /// The [image] field is nullable
  final image = map[BookmarkMapperFields.image] as Uint8List?;

  /// The [providerName] field is nullable
  final providerName = map[BookmarkMapperFields.providerName];

  /// The [favicon] field is nullable
  final favicon = map[BookmarkMapperFields.providerThumbnail] as String?;

  final url = map[BookmarkMapperFields.url] ?? '';

  final createdAt =
      map[BookmarkMapperFields.createdAt] ?? throwMapperException() as String;

  return Bookmark(
    id: UniqueId.fromTrustedString(id),
    collectionId: UniqueId.fromTrustedString(collectionId),
    title: title,
    image: image,
    provider: DocumentProvider(
      name: providerName,
      favicon: favicon,
    ),
    createdAt: createdAt,
    uri: Uri.parse(url),
  );
}

DbEntityMap bookmarkToMap(Bookmark entity) => {
      BookmarkMapperFields.id: entity.id.value,
      BookmarkMapperFields.collectionId: entity.collectionId.value,
      BookmarkMapperFields.title: entity.title,
      BookmarkMapperFields.image: entity.image,
      BookmarkMapperFields.providerName: entity.provider?.name,
      BookmarkMapperFields.providerThumbnail: entity.provider?.favicon,
      BookmarkMapperFields.createdAt: entity.createdAt,
      BookmarkMapperFields.url: entity.url,
    };

void throwMapperException([
  String exceptionText =
      'error occurred while mapping the object during migration',
]) =>
    throw DbEntityMapperException(exceptionText);
