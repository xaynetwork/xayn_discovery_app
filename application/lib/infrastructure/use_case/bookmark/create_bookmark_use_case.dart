import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';

@injectable
class CreateBookmarkUseCase extends UseCase<CreateBookmarkUseCaseParam, None> {
  final BookmarksRepository _bookmarksRepository;

  CreateBookmarkUseCase(this._bookmarksRepository);
  @override
  Stream<None> transaction(CreateBookmarkUseCaseParam param) async* {
    final bookmark = Bookmark(
      id: UniqueId(),
      collectionId: param.collectionId,
      title: param.title,
      image: param.image,
      providerName: param.providerName,
      providerThumbnail: param.providerThumbnail,
      createdAt: DateTime.now().toUtc().toString(),
    );
    _bookmarksRepository.bookmark = bookmark;
    yield none;
  }
}

class CreateBookmarkUseCaseParam {
  final String title;
  final Uint8List image;
  final String providerName;
  final Uint8List providerThumbnail;
  final UniqueId collectionId;

  CreateBookmarkUseCaseParam({
    required this.title,
    required this.image,
    required this.providerName,
    required this.providerThumbnail,
    required this.collectionId,
  });
}
