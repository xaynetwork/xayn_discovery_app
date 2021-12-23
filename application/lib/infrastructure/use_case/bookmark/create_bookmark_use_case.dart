import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';

@injectable
class CreateBookmarkUseCase
    extends UseCase<CreateBookmarkUseCaseParam, Bookmark> {
  final BookmarksRepository _bookmarksRepository;
  final UniqueIdHandler _uniqueIdHandler;
  final DateTimeHandler _dateTimeHandler;

  CreateBookmarkUseCase(
    this._bookmarksRepository,
    this._uniqueIdHandler,
    this._dateTimeHandler,
  );

  @override
  Stream<Bookmark> transaction(CreateBookmarkUseCaseParam param) async* {
    final uniqueId = _uniqueIdHandler.generateUniqueId();
    final dateTime = _dateTimeHandler.getDateTimeNow();
    final bookmark = Bookmark(
      id: uniqueId,
      collectionId: param.collectionId,
      title: param.title,
      image: param.image,
      providerName: param.providerName,
      providerThumbnail: param.providerThumbnail,
      createdAt: dateTime.toUtc().toString(),
    );
    _bookmarksRepository.bookmark = bookmark;
    yield bookmark;
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
