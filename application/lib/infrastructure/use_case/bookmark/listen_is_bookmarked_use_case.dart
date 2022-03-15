import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

/// Pass DocumentId of a bookmark and listen to repository changes then expect a stream if it was bookmarked or not
@injectable
class ListenIsBookmarkedUseCase extends UseCase<UniqueId, bool> {
  final BookmarksRepository _bookmarksRepository;

  ListenIsBookmarkedUseCase(this._bookmarksRepository);

  @override
  Stream<bool> transaction(UniqueId param) async* {
    // initial event
    yield _bookmarksRepository.getById(param) != null;

    // changes & deletes are from now on watched
    yield* _bookmarksRepository
        .watch()
        .where((event) => event.id == param)
        .map((_) => _bookmarksRepository.getById(param))
        .distinct()
        .map((event) => event != null);
  }
}
