import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';

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
    extends UseCase<CreateBookmarkUseCaseParam, Bookmark> {
  final BookmarksRepository _bookmarksRepository;

  CreateBookmarkUseCase(this._bookmarksRepository);

  @override
  Stream<Bookmark> transaction(CreateBookmarkUseCaseParam param) async* {
    final bookmark = Bookmark(
      id: param.id,
      collectionId: param.collectionId,
      title: param.title,
      image: param.image,
      providerName: param.providerName,
      providerThumbnail: param.providerThumbnail,
      createdAt: DateTime.now().toUtc().toString(),
    );
    _bookmarksRepository.bookmark = bookmark;
    yield bookmark;
  }
}

@injectable
class MapDocumentToCreateBookmarkParamUseCase
    extends UseCase<Document, CreateBookmarkUseCaseParam> {
  final DirectUriUseCase _directUriUseCase;

  MapDocumentToCreateBookmarkParamUseCase(this._directUriUseCase);

  @override
  Stream<CreateBookmarkUseCaseParam> transaction(Document param) async* {
    final webResource = param.webResource;
    final image = await _directUriUseCase.singleOutput(webResource.displayUrl);

    final thumbnailUrl = webResource.provider?.thumbnail;

    Uri? thumbnailUri;
    CacheManagerEvent? providerThumbnail;

    if (thumbnailUrl != null) {
      thumbnailUri = Uri.parse(thumbnailUrl);
      providerThumbnail = await _directUriUseCase.singleOutput(thumbnailUri);
    }

    final createBookmarkParam = CreateBookmarkUseCaseParam(
      /// Bookmark Id should be the same as Document Id
      /// ``` document.documentId.key == bookmark.id.value; ```
      id: UniqueId.fromTrustedString(param.documentId.key),

      title: webResource.title,
      image: image.bytes,
      providerName: webResource.provider?.name,
      providerThumbnail: providerThumbnail?.bytes,
    );

    yield createBookmarkParam;
  }
}

class CreateBookmarkUseCaseParam {
  final UniqueId id;
  final String title;
  final Uint8List? image;
  final String? providerName;
  final Uint8List? providerThumbnail;
  final UniqueId collectionId;

  CreateBookmarkUseCaseParam({
    required this.id,
    required this.title,
    required this.image,
    required this.providerName,
    required this.providerThumbnail,
    this.collectionId = Collection.readLaterId,
  });
}
