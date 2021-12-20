import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

@injectable
class RemoveBookmarkUseCase extends UseCase<UniqueId, None> {
  final BookmarksRepository _bookmarksRepository;
  RemoveBookmarkUseCase(this._bookmarksRepository);

  @override
  Stream<None> transaction(UniqueId param) async* {
    final bookmark = _bookmarksRepository.getById(param);
    if (bookmark != null) {
      _bookmarksRepository.remove(bookmark);
    }
    yield none;
  }
}
