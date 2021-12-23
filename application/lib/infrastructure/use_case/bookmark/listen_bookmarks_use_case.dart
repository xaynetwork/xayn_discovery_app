import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

@injectable
class ListenBookmarksUseCase extends UseCase<UniqueId, List<Bookmark>> {
  final BookmarksRepository _bookmarksRepository;

  ListenBookmarksUseCase(this._bookmarksRepository);
  @override
  Stream<List<Bookmark>> transaction(UniqueId param) =>
      _bookmarksRepository.watch().map(
            (_) => _bookmarksRepository.getByCollectionId(param),
          );
}
