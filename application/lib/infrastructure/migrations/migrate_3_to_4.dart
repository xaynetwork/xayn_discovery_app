import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/bookmark_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/crud_entity_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/uri_extensions.dart';

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
      mapper: DocumentMapper(),
    );
    final bookmarkBoxRepository = CrudEntityRepository<Bookmark>(
      box: 'bookmarks',
      mapper: BookmarkMapper(),
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
