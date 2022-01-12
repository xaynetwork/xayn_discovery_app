import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

/// Pass DocumentId of a bookmark and expect a stream if it was bookmarked or not
@injectable
class IsBookmarkedUseCase extends UseCase<UniqueId, bool> {
  final BookmarksRepository _bookmarksRepository;

  IsBookmarkedUseCase(this._bookmarksRepository);

  @override
  Stream<bool> transaction(UniqueId param) async* {
    final bookmark = _bookmarksRepository.getById(param);
    yield bookmark != null;
  }
}
