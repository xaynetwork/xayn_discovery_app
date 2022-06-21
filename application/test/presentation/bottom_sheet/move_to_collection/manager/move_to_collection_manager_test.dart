import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_bookmarked_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../../../test_utils/fakes.dart';
import '../../../../test_utils/utils.dart';

void main() {
  group('Move document to collection manager ', () {
    late MockListenCollectionsUseCase listenCollectionsUseCase;
    late MockMoveBookmarkUseCase moveBookmarkUseCase;
    late MockRemoveBookmarkUseCase removeBookmarkUseCase;
    late MockCreateBookmarkFromDocumentUseCase
        createBookmarkFromDocumentUseCase;
    late MockGetBookmarkUseCase getBookmarkUseCase;
    late MockCollectionsRepository collectionsRepository;

    late MoveToCollectionState populatedState;
    late MoveToCollectionManager moveDocumentToCollectionManager;

    late MockChangeDocumentFeedbackUseCase changeDocumentFeedbackUseCase;
    late MockSendAnalyticsUseCase sendAnalyticsUseCase;

    final collection1 =
        Collection(id: UniqueId(), name: 'Collection1 name', index: 0);
    final collection2 =
        Collection(id: UniqueId(), name: 'Collection2 name', index: 1);

    final bookmark = fakeBookmark.copyWith(collectionId: collection1.id);

    di.registerLazySingleton<ChangeDocumentFeedbackUseCase>(
        () => changeDocumentFeedbackUseCase);
    di.registerLazySingleton<SendAnalyticsUseCase>(() => sendAnalyticsUseCase);

    createDocumentMarkedPositive() => Document(
          documentId: DocumentId(),
          resource: NewsResource(
            image: Uri.parse('https://displayUrl.test.xayn.com'),
            sourceDomain: Source('example'),
            topic: 'topic',
            score: .0,
            rank: -1,
            language: 'en-US',
            country: 'US',
            snippet: 'snippet',
            title: 'title',
            url: Uri.parse('https://url.test.xayn.com'),
            datePublished: DateTime.parse("2021-01-01 00:00:00.000Z"),
          ),
          batchIndex: -1,
          userReaction: UserReaction.positive,
        );

    final documentMarkedPositive = createDocumentMarkedPositive();

    void _mockManagerInitMethodCalls() {
      when(collectionsRepository.getAll()).thenAnswer(
        (_) => [
          collection1,
          collection2,
        ],
      );

      when(listenCollectionsUseCase.transform(any)).thenAnswer(
        (_) => const Stream.empty(),
      );

      when(moveBookmarkUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(removeBookmarkUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(createBookmarkFromDocumentUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(changeDocumentFeedbackUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(sendAnalyticsUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(removeBookmarkUseCase.transaction(any))
          .thenAnswer((_) => Stream.value(fakeBookmark));

      when(moveBookmarkUseCase.transaction(any))
          .thenAnswer((_) => Stream.value(fakeBookmark));

      when(createBookmarkFromDocumentUseCase.transaction(any))
          .thenAnswer((_) => Stream.value(fakeBookmark));

      when(changeDocumentFeedbackUseCase.transaction(any))
          .thenAnswer((invocation) => const Stream.empty());

      when(sendAnalyticsUseCase.transaction(any))
          .thenAnswer((invocation) => const Stream.empty());
    }

    Future<MoveToCollectionManager> createManager() async =>
        MoveToCollectionManager.create(
          collectionsRepository,
          listenCollectionsUseCase,
          moveBookmarkUseCase,
          removeBookmarkUseCase,
          getBookmarkUseCase,
          createBookmarkFromDocumentUseCase,
          sendAnalyticsUseCase,
        );

    setUp(() async {
      listenCollectionsUseCase = MockListenCollectionsUseCase();
      moveBookmarkUseCase = MockMoveBookmarkUseCase();
      removeBookmarkUseCase = MockRemoveBookmarkUseCase();
      createBookmarkFromDocumentUseCase =
          MockCreateBookmarkFromDocumentUseCase();
      getBookmarkUseCase = MockGetBookmarkUseCase();
      collectionsRepository = MockCollectionsRepository();
      changeDocumentFeedbackUseCase = MockChangeDocumentFeedbackUseCase();
      sendAnalyticsUseCase = MockSendAnalyticsUseCase();

      populatedState = MoveToCollectionState.populated(
        collections: [collection1, collection2],
        selectedCollectionId: null,
        isBookmarked: false,
        shouldClose: false,
      );

      _mockManagerInitMethodCalls();
      moveDocumentToCollectionManager = await createManager();
    });

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN MoveDocumentToCollectionManager is created THEN get values and emit MoveDocumentToCollectionStatePopulated ',
      build: () => moveDocumentToCollectionManager,
      expect: () => [
        populatedState,
      ],
      verify: (manager) {
        verifyInOrder([
          collectionsRepository.getAll(),
          listenCollectionsUseCase.transform(any),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
        verifyNoMoreInteractions(listenCollectionsUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called AND bookmark is found THEN update isBookmarked state',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => Future.value(bookmark),
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(bookmarkId: bookmark.id);
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(
          isBookmarked: true,
          selectedCollectionId: collection1.id,
        )
      ],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called AND no bookmark found THEN do not update isBookmarked state',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => throw BookmarkUseCaseError.tryingToGetNotExistingBookmark,
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(bookmarkId: bookmark.id);
      },
      expect: () => [populatedState],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called with initialSelectedCollectionId AND no bookmark found THEN update collection state with false isBookmarked',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => throw BookmarkUseCaseError.tryingToGetNotExistingBookmark,
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(
          bookmarkId: bookmark.id,
          initialSelectedCollectionId: collection2.id,
        );
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(
          selectedCollectionId: collection2.id,
          isBookmarked: false,
        ),
      ],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called with initialSelectedCollectionId AND bookmark is found THEN update collection state with true isBookmarked',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => Future.value(bookmark),
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(
          bookmarkId: bookmark.id,
          initialSelectedCollectionId: collection2.id,
        );
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(
          selectedCollectionId: collection2.id,
          isBookmarked: true,
        ),
      ],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = false and selectedCollection != null THEN call CreateBookmarkFromDocumentUseCase ',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
              UseCaseResult.success(
                DocumentBookmarkedEvent(
                  document: documentMarkedPositive,
                  isBookmarked: true,
                  toDefaultCollection: true,
                ),
              )
            ]);
      },
      seed: () => populatedState.copyWith(
        selectedCollectionId: collection2.id,
        isBookmarked: false,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
          changeDocumentFeedbackUseCase.transform(any),
          sendAnalyticsUseCase.call(any),
          createBookmarkFromDocumentUseCase.transaction(any),
          sendAnalyticsUseCase.call(any),
          changeDocumentFeedbackUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
        verifyNoMoreInteractions(sendAnalyticsUseCase);
        verifyNoMoreInteractions(changeDocumentFeedbackUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = true and selectedCollection != null THEN call MoveBookmarkUseCase ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollectionId: collection2.id,
        isBookmarked: true,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
          moveBookmarkUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = true and selectedCollection = null THEN call RemoveBookmarkUseCase ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollectionId: null,
        isBookmarked: true,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = false and selectedCollection = null THEN do not expect calls ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollectionId: null,
        isBookmarked: false,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      expect: () => [],
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );
  });
}
