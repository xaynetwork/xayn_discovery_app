import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/manager/delete_collection_confirmation_manager.dart';

import 'delete_collection_confirmation_manager_test.mocks.dart';

@GenerateMocks([
  RemoveCollectionUseCase,
  RemoveBookmarskUseCase,
  GetAllBookmarksUseCase,
])
void main() {
  late MockRemoveCollectionUseCase removeCollectionUseCase;
  late MockRemoveBookmarskUseCase removeBookmarskUseCase;
  late MockGetAllBookmarksUseCase getAllBookmarksUseCase;
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
      removeBookmarskUseCase = MockRemoveBookmarskUseCase();
      getAllBookmarksUseCase = MockGetAllBookmarksUseCase();
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
          removeBookmarskUseCase.call(any),
        ).thenAnswer((_) => Future.value([
              UseCaseResult.success(
                RemoveBookmarskUseCaseOut(
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
        removeBookmarskUseCase,
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
      ]);
      verifyNoMoreInteractions(getAllBookmarksUseCase);
      verifyNoMoreInteractions(removeCollectionUseCase);
    },
  );

  blocTest(
    'WHEN deleteAll is called THEN call removeBookmarskUseCase and removeCollectionUseCase with the proper collection id',
    build: () => deleteCollectionConfirmationManager,
    act: (manager) {
      deleteCollectionConfirmationManager.enteringScreen(collection.id);
      deleteCollectionConfirmationManager.deleteAll();
    },
    verify: (manager) {
      verifyInOrder([
        getAllBookmarksUseCase.transform(any),
        removeBookmarskUseCase.call(any),
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
      ]);
      verifyNoMoreInteractions(getAllBookmarksUseCase);
      verifyNoMoreInteractions(removeBookmarskUseCase);
      verifyNoMoreInteractions(removeCollectionUseCase);
    },
  );
}
