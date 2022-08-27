import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/cache_manager/cache_manager_event.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/user_interactions_events.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class CreateBookmarkFromDocumentUseCase
    extends UseCase<CreateBookmarkFromDocumentUseCaseIn, Bookmark> {
  final MapDocumentToCreateBookmarkParamUseCase _mapper;
  final CreateBookmarkUseCase _createBookmark;
  final DocumentRepository _documentRepository;
  final SaveUserInteractionUseCase _saveUserInteractionUseCase;

  CreateBookmarkFromDocumentUseCase(
    this._mapper,
    this._createBookmark,
    this._documentRepository,
    this._saveUserInteractionUseCase,
  );

  @override
  Stream<Bookmark> transaction(
      CreateBookmarkFromDocumentUseCaseIn param) async* {
    final createBookmarkParam = await _mapper.singleOutput(param);
    final bookmark = await _createBookmark.singleOutput(createBookmarkParam);
    final document =
        _documentRepository.getByDocumentId(param.document.documentId);
    _documentRepository.save(
      DocumentWrapper(
        param.document,
        isEngineDocument: document?.isEngineDocument ?? true,
      ),
    );

    _saveUserInteractionUseCase
        .singleOutput(UserInteractionsEvents.bookmarkedArticle);

    yield bookmark;
  }

  @override
  Stream<CreateBookmarkFromDocumentUseCaseIn> transform(
          Stream<CreateBookmarkFromDocumentUseCaseIn> incoming) =>
      incoming.distinct();
}

@injectable
class CreateBookmarkUseCase extends UseCase<CreateBookmarkUseCaseIn, Bookmark> {
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
      documentId: param.documentId,
      collectionId: param.collectionId,
      title: param.title,
      image: param.image,
      provider: param.provider,
      createdAt: dateTime.toUtc().toString(),
      uri: param.url,
    );
    _bookmarksRepository.save(bookmark);
    yield bookmark;
  }
}

@injectable
class MapDocumentToCreateBookmarkParamUseCase extends UseCase<
    CreateBookmarkFromDocumentUseCaseIn, CreateBookmarkUseCaseIn> {
  final DirectUriUseCase _directUriUseCase;

  MapDocumentToCreateBookmarkParamUseCase(this._directUriUseCase);

  @override
  Stream<CreateBookmarkUseCaseIn> transaction(
      CreateBookmarkFromDocumentUseCaseIn param) async* {
    final resource = param.document.resource;
    final image = await _getImageData(resource.image);

    final createBookmarkUseCaseIn = CreateBookmarkUseCaseIn(
      documentId: param.document.documentUniqueId,
      title: resource.title,
      image: image,
      provider: param.provider ?? DocumentProvider(),
      collectionId: param.collectionId,
      url: param.document.resource.url,
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
  final UniqueId documentId;
  final String title;
  final Uint8List? image;
  final DocumentProvider? provider;
  final UniqueId collectionId;
  final Uri url;

  CreateBookmarkUseCaseIn({
    required this.documentId,
    required this.title,
    required this.image,
    required this.provider,
    required this.url,
    this.collectionId = Collection.readLaterId,
  });
}

class CreateBookmarkFromDocumentUseCaseIn {
  final Document document;
  final FeedType? feedType;
  final DocumentProvider? provider;
  final UniqueId collectionId;

  CreateBookmarkFromDocumentUseCaseIn({
    required this.document,
    this.feedType,
    this.provider,
    this.collectionId = Collection.readLaterId,
  });
}
