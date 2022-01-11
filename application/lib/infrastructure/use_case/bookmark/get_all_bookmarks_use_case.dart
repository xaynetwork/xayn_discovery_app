import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

@injectable
class GetAllBookmarksUseCase extends UseCase<None, GetAllBookmarksUseCaseOut> {
  final BookmarksRepository _bookmarksRepository;

  GetAllBookmarksUseCase(this._bookmarksRepository);
  @override
  Stream<GetAllBookmarksUseCaseOut> transaction(None param) async* {
    final bookmarks = _bookmarksRepository.getAll();
    yield GetAllBookmarksUseCaseOut(bookmarks);
  }
}

class GetAllBookmarksUseCaseOut extends Equatable {
  final List<Bookmark> bookmarks;

  const GetAllBookmarksUseCaseOut(this.bookmarks);

  @override
  List<Object?> get props => bookmarks;
}
