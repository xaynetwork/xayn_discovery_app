import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class ToggleBookmarkUseCase extends UseCase<CreateBookmarkFromDocumentUseCaseIn,
    ToggleBookmarkUseCaseOut> {
  final CreateBookmarkFromDocumentUseCase _createBookmarkUseCase;
  final RemoveBookmarkUseCase _removeBookmarkUseCase;
  final IsBookmarkedUseCase _isBookmarkedUseCase;

  ToggleBookmarkUseCase(
    this._isBookmarkedUseCase,
    this._createBookmarkUseCase,
    this._removeBookmarkUseCase,
  );

  @override
  Stream<ToggleBookmarkUseCaseOut> transaction(
      CreateBookmarkFromDocumentUseCaseIn param) async* {
    final bookmarkId = param.document.documentUniqueId;
    final isBookmarked = await _isBookmarkedUseCase.singleOutput(bookmarkId);
    final bookmark = isBookmarked
        ? await _removeBookmarkUseCase.singleOutput(bookmarkId)
        : await _createBookmarkUseCase.singleOutput(param);
    yield ToggleBookmarkUseCaseOut(
      document: param.document,
      bookmark: bookmark,
      isBookmarked: !isBookmarked,
      feedType: param.feedType,
    );
  }
}

class ToggleBookmarkUseCaseOut {
  final Document document;
  final Bookmark bookmark;
  final bool isBookmarked;
  final FeedType? feedType;

  ToggleBookmarkUseCaseOut({
    required this.document,
    required this.bookmark,
    required this.isBookmarked,
    this.feedType,
  });
}
