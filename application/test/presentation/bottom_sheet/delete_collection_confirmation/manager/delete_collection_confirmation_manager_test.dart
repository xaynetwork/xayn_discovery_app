import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/collection_deleted_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/manager/delete_collection_confirmation_manager.dart';

import '../../../../test_utils/utils.dart';

void main() {
  late MockRemoveCollectionUseCase removeCollectionUseCase;
  late MockRemoveBookmarksUseCase removeBookmarksUseCase;
  late MockGetAllBookmarksUseCase getAllBookmarksUseCase;
  late MockSendAnalyticsUseCase sendAnalyticsUseCase;
  late DeleteCollectionConfirmationManager deleteCollectionConfirmationManager;

  final collection = Collection(
    id: UniqueId(),
    name: 'Collection test',
    index: 2,
  );

  final bookmarks = [
    Bookmark(
      collectionId: collection.id,
      id: UniqueId(),
      title: 'Bookmark1',
      provider: DocumentProvider(),
      image: Uint8List.fromList([1, 2, 3]),
      createdAt: DateTime.now().toString(),
    ),
    Bookmark(
      collectionId: collection.id,
      id: UniqueId(),
      title: 'Bookmark2',
      provider: DocumentProvider(),
      image: Uint8List.fromList([1, 2, 3]),
      createdAt: DateTime.now().toString(),
    ),
  ];

  final bookmarksIds = bookmarks.map((e) => e.id).toList();

  setUp(
    () {
      removeCollectionUseCase = MockRemoveCollectionUseCase();
      removeBookmarksUseCase = MockRemoveBookmarksUseCase();
      getAllBookmarksUseCase = MockGetAllBookmarksUseCase();
      sendAnalyticsUseCase = MockSendAnalyticsUseCase();
      void _mockManagerInitMethodCalls() {
        when(
          getAllBookmarksUseCase.transform(any),
        ).thenAnswer((invocation) => invocation.positionalArguments.first);

        when(getAllBookmarksUseCase.transaction(any)).thenAnswer(
          (_) => Stream.value(
            GetAllBookmarksUseCaseOut(
              bookmarks,
            ),
          ),
        );

        when(
          removeBookmarksUseCase.call(any),
        ).thenAnswer((_) => Future.value([
              UseCaseResult.success(
                RemoveBookmarksUseCaseOut(
                  removedBookmarks: bookmarks,
                ),
              )
            ]));

        when(removeCollectionUseCase.call(RemoveCollectionUseCaseParam(
                collectionIdToRemove: collection.id)))
            .thenAnswer(
                (_) => Future.value([UseCaseResult.success(collection)]));
      }

      _mockManagerInitMethodCalls();
      deleteCollectionConfirmationManager = DeleteCollectionConfirmationManager(
        removeCollectionUseCase,
        getAllBookmarksUseCase,
        removeBookmarksUseCase,
        sendAnalyticsUseCase,
      );
    },
  );

  blocTest(
    'WHEN manager is created THEN the transform method of getAllBookmarksUseCase is called because of the usage of pipe',
    build: () => deleteCollectionConfirmationManager,
    verify: (manager) {
      verifyInOrder([
        getAllBookmarksUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(getAllBookmarksUseCase);
    },
  );

  blocTest(
    'WHEN enteringScreen is called THEN call getAllBookmarksUseCase with the proper collection id',
    build: () => deleteCollectionConfirmationManager,
    act: (manager) =>
        deleteCollectionConfirmationManager.enteringScreen(collection.id),
    verify: (manager) {
      verifyInOrder([
        getAllBookmarksUseCase.transform(any),
        getAllBookmarksUseCase.transaction(
          GetAllBookmarksUseCaseIn(
            collectionId: collection.id,
          ),
        ),
      ]);
      verifyNoMoreInteractions(getAllBookmarksUseCase);
      expect(
        deleteCollectionConfirmationManager.state.bookmarksIds,
        bookmarksIds,
      );
    },
  );

  blocTest(
    'WHEN deleteCollection is called THEN call removeCollectionUseCase with the proper collection id',
    build: () => deleteCollectionConfirmationManager,
    setUp: () {
      when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
            UseCaseResult.success(
              CollectionDeletedEvent(
                context: DeleteCollectionContext.empty,
              ),
            )
          ]);
    },
    act: (manager) {
      deleteCollectionConfirmationManager.enteringScreen(collection.id);
      deleteCollectionConfirmationManager.deleteCollection();
    },
    verify: (manager) {
      verifyInOrder([
        getAllBookmarksUseCase.transform(any),
        removeCollectionUseCase.call(
          RemoveCollectionUseCaseParam(
            collectionIdToRemove: collection.id,
          ),
        ),
        getAllBookmarksUseCase.transaction(
          GetAllBookmarksUseCaseIn(
            collectionId: collection.id,
          ),
        ),
        sendAnalyticsUseCase.call(any),
      ]);
      verifyNoMoreInteractions(getAllBookmarksUseCase);
      verifyNoMoreInteractions(removeCollectionUseCase);
      verifyNoMoreInteractions(sendAnalyticsUseCase);
    },
  );

  blocTest(
    'WHEN deleteAll is called THEN call removeBookmarksUseCase and removeCollectionUseCase with the proper collection id',
    build: () => deleteCollectionConfirmationManager,
    setUp: () {
      when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
            UseCaseResult.success(
              CollectionDeletedEvent(
                context: DeleteCollectionContext.deleteBookmarks,
              ),
            )
          ]);
    },
    act: (manager) {
      deleteCollectionConfirmationManager.enteringScreen(collection.id);
      deleteCollectionConfirmationManager.deleteAll();
    },
    verify: (manager) {
      verifyInOrder([
        getAllBookmarksUseCase.transform(any),
        removeBookmarksUseCase.call(any),
        getAllBookmarksUseCase.transaction(
          GetAllBookmarksUseCaseIn(
            collectionId: collection.id,
          ),
        ),
        removeCollectionUseCase.call(
          RemoveCollectionUseCaseParam(
            collectionIdToRemove: collection.id,
          ),
        ),
        sendAnalyticsUseCase.call(any),
      ]);
      verifyNoMoreInteractions(getAllBookmarksUseCase);
      verifyNoMoreInteractions(removeBookmarksUseCase);
      verifyNoMoreInteractions(removeCollectionUseCase);
    },
  );
}
