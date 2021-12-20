import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

@injectable
class GetAllBookmarksUseCase extends UseCase<None, List<Bookmark>> {
  final BookmarksRepository _bookmarksRepository;

  GetAllBookmarksUseCase(this._bookmarksRepository);
  @override
  Stream<List<Bookmark>> transaction(None param) async* {
    yield _bookmarksRepository.getAll();
  }
}
