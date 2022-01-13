import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class CreateBookmarkFromDocumentUseCase extends UseCase<Document, Bookmark> {
  final MapDocumentToCreateBookmarkParamUseCase _mapper;
  final CreateBookmarkUseCase _createBookmark;

  CreateBookmarkFromDocumentUseCase(this._mapper, this._createBookmark);

  @override
  Stream<Bookmark> transaction(Document param) async* {
    final createBookmarkParam = await _mapper.singleOutput(param);
    final bookmark = await _createBookmark.singleOutput(createBookmarkParam);
    yield bookmark;
  }

  @override
  Stream<Document> transform(Stream<Document> incoming) => incoming.distinct();
}

@injectable
class CreateBookmarkUseCase
    extends UseCase<CreateBookmarkUseCaseIn, Bookmark> {
  final BookmarksRepository _bookmarksRepository;
  final DateTimeHandler _dateTimeHandler;

  CreateBookmarkUseCase(
      this._bookmarksRepository,
      this._dateTimeHandler,
      );

  @override
  Stream<Bookmark> transaction(CreateBookmarkUseCaseIn param) async* {
    final dateTime = _dateTimeHandler.getDateTimeNow();
    final bookmark = Bookmark(
      id: param.id,
      collectionId: param.collectionId,
      title: param.title,
      image: param.image,
      providerName: param.providerName,
      providerThumbnail: param.providerThumbnail,
      createdAt: dateTime.toUtc().toString(),
    );
    _bookmarksRepository.save(bookmark);
    yield bookmark;
  }
}

@injectable
class MapDocumentToCreateBookmarkParamUseCase
    extends UseCase<Document, CreateBookmarkUseCaseIn> {
  final DirectUriUseCase _directUriUseCase;

  MapDocumentToCreateBookmarkParamUseCase(this._directUriUseCase);

  @override
  Stream<CreateBookmarkUseCaseIn> transaction(Document param) async* {
    final webResource = param.webResource;
    final image = await _getImageData(webResource.displayUrl);
    final thumbnailUri = webResource.provider?.thumbnail;
    final providerThumbnail = await _getImageData(thumbnailUri);

    final createBookmarkUseCaseIn = CreateBookmarkUseCaseIn(
      id: param.documentUniqueId,
      title: webResource.title,
      image: image,
      providerName: webResource.provider?.name,
      providerThumbnail: providerThumbnail,
    );
    yield createBookmarkUseCaseIn;
  }

  Future<Uint8List?> _getImageData(Uri? uri) async {
    if (uri == null) return null;
    final list = await _directUriUseCase.call(uri);
    final last = list.last;
    Object? error;
    late CacheManagerEvent value;
    last.fold(defaultOnError: (e, _) => error = e, onValue: (it) => value = it);
    if (error != null) throw error!;
    return value.bytes;
  }
}

class CreateBookmarkUseCaseIn {
  final UniqueId id;
  final String title;
  final Uint8List? image;
  final String? providerName;
  final Uint8List? providerThumbnail;
  final UniqueId collectionId;

  CreateBookmarkUseCaseIn({
    required this.id,
    required this.title,
    required this.image,
    required this.providerName,
    required this.providerThumbnail,
    this.collectionId = Collection.readLaterId,
  });
}
