import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

import 'collections_screen_manager_test.mocks.dart';

@GenerateMocks([
  CreateCollectionUseCase,
  RemoveCollectionUseCase,
  RenameCollectionUseCase,
  ListenCollectionsUseCase,
  GetAllCollectionsUseCase,
  GetAllBookmarksUseCase,
  CollectionErrorsEnumMapper,
  DateTimeHandler,
])
void main() {
  late MockCreateCollectionUseCase createCollectionUseCase;
  late MockRemoveCollectionUseCase removeCollectionUseCase;
  late MockRenameCollectionUseCase renameCollectionUseCase;
  late MockListenCollectionsUseCase listenCollectionsUseCase;
  late MockGetAllCollectionsUseCase getAllCollectionsUseCase;
  late MockCollectionErrorsEnumMapper collectionErrorsEnumMapper;
  late MockDateTimeHandler dateTimeHandler;
  late CollectionsScreenState populatedState;
  final timeStamp = DateTime.now();
  const newCollectionName = 'New Collection Name';
  final collection1 =
      Collection(id: UniqueId(), name: 'Collection1 name', index: 0);
  final collection2 =
      Collection(id: UniqueId(), name: 'Collection2 name', index: 1);
  final newCollection =
      Collection(id: UniqueId(), name: 'Collection3 name', index: 2);
  late CollectionsScreenManager collectionsScreenManager;

  void _mockManagerInitMethodCalls() {
    when(getAllCollectionsUseCase.singleOutput(none)).thenAnswer(
      (_) => Future.value(
        GetAllCollectionsUseCaseOut(
          [
            collection1,
            collection2,
          ],
        ),
      ),
    );

    when(listenCollectionsUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timeStamp);
  }

  Future<CollectionsScreenManager> createManager() async =>
      await CollectionsScreenManager.create(
        createCollectionUseCase,
        getAllCollectionsUseCase,
        removeCollectionUseCase,
        renameCollectionUseCase,
        listenCollectionsUseCase,
        collectionErrorsEnumMapper,
        dateTimeHandler,
      );

  setUp(() async {
    createCollectionUseCase = MockCreateCollectionUseCase();
    removeCollectionUseCase = MockRemoveCollectionUseCase();
    renameCollectionUseCase = MockRenameCollectionUseCase();
    listenCollectionsUseCase = MockListenCollectionsUseCase();
    getAllCollectionsUseCase = MockGetAllCollectionsUseCase();
    collectionErrorsEnumMapper = MockCollectionErrorsEnumMapper();
    dateTimeHandler = MockDateTimeHandler();
    populatedState = CollectionsScreenState.populated(
      [collection1, collection2],
      timeStamp,
    );

    _mockManagerInitMethodCalls();
    collectionsScreenManager = await createManager();
  });

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN manager is created THEN get values and emit CollectionsScreenStatePopulated ',
    build: () => collectionsScreenManager,
    expect: () => [
      populatedState,
    ],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN create collection method is called THEN call CreateCollectionUseCase ',
    build: () => collectionsScreenManager,
    setUp: () {
      when(createCollectionUseCase.call(newCollection.name)).thenAnswer(
        (_) => Future.value([UseCaseResult.success(collection1)]),
      );
    },
    act: (manager) {
      manager.createCollection(collectionName: newCollection.name);
    },
    //default one, emitted when manager created
    expect: () => [populatedState],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
        createCollectionUseCase.call(newCollection.name),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(createCollectionUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN createCollectionUsecase returns throws an error THEN return current state with error message',
    build: () => collectionsScreenManager,
    setUp: () {
      when(createCollectionUseCase.call(newCollection.name)).thenAnswer(
        (_) => Future.value(
          [
            const UseCaseResult.failure(
              CollectionUseCaseError.tryingToCreateCollectionUsingExistingName,
              null,
            )
          ],
        ),
      );

      when(collectionErrorsEnumMapper.mapEnumToString(
        CollectionUseCaseError.tryingToCreateCollectionUsingExistingName,
      )).thenReturn(Strings.errorMsgTryingToCreateCollectionUsingExistingName);
    },
    act: (manager) {
      manager.createCollection(collectionName: newCollection.name);
    },
    expect: () => [
      //default one, emitted when manager created
      populatedState,
      populatedState.copyWith(
          errorMsg: Strings.errorMsgTryingToCreateCollectionUsingExistingName),
    ],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
        createCollectionUseCase.call(newCollection.name),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(createCollectionUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN renameCollection method is called THEN call RenameCollectionUseCase ',
    build: () => collectionsScreenManager,
    setUp: () {
      when(
        renameCollectionUseCase.call(
          RenameCollectionUseCaseParam(
            collectionId: collection1.id,
            newName: newCollectionName,
          ),
        ),
      ).thenAnswer(
        (_) => Future.value(
          [
            UseCaseResult.success(
              collection1.copyWith(
                name: newCollectionName,
              ),
            )
          ],
        ),
      );
    },
    act: (manager) => manager.renameCollection(
      collectionId: collection1.id,
      newName: newCollectionName,
    ),

    //default one, emitted when manager created
    expect: () => [populatedState],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
        renameCollectionUseCase.call(
          RenameCollectionUseCaseParam(
            collectionId: collection1.id,
            newName: newCollectionName,
          ),
        ),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(renameCollectionUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN renameCollectionUsecase returns throws an error THEN return current state with error message',
    build: () => collectionsScreenManager,
    setUp: () {
      when(
        renameCollectionUseCase.call(
          RenameCollectionUseCaseParam(
            collectionId: collection1.id,
            newName: newCollectionName,
          ),
        ),
      ).thenAnswer(
        (_) => Future.value(
          [
            const UseCaseResult.failure(
              CollectionUseCaseError.tryingToRenameCollectionUsingExistingName,
              null,
            )
          ],
        ),
      );

      when(collectionErrorsEnumMapper.mapEnumToString(
        CollectionUseCaseError.tryingToRenameCollectionUsingExistingName,
      )).thenReturn(Strings.errorMsgTryingToRenameCollectionUsingExistingName);
    },
    act: (manager) => manager.renameCollection(
      collectionId: collection1.id,
      newName: newCollectionName,
    ),
    expect: () => [
      //default one, emitted when manager created
      populatedState,
      populatedState.copyWith(
          errorMsg: Strings.errorMsgTryingToRenameCollectionUsingExistingName),
    ],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
        renameCollectionUseCase.call(
          RenameCollectionUseCaseParam(
            collectionId: collection1.id,
            newName: newCollectionName,
          ),
        ),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(renameCollectionUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN removeCollection is called THEN call RemoveCollectionUseCase ',
    build: () => collectionsScreenManager,
    setUp: () {
      when(
        removeCollectionUseCase.call(
          RemoveCollectionUseCaseParam(
            collectionIdToRemove: collection1.id,
          ),
        ),
      ).thenAnswer(
        (_) => Future.value(
          [
            UseCaseResult.success(
              collection1,
            )
          ],
        ),
      );
    },
    act: (manager) => manager.removeCollection(
      collectionIdToRemove: collection1.id,
    ),

    //default one, emitted when manager created
    expect: () => [populatedState],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
        removeCollectionUseCase.call(
          RemoveCollectionUseCaseParam(
            collectionIdToRemove: collection1.id,
          ),
        ),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(removeCollectionUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN removeCollectionUseCase returns throws an error THEN return current state with error message',
    build: () => collectionsScreenManager,
    setUp: () {
      when(
        removeCollectionUseCase.call(
          RemoveCollectionUseCaseParam(
            collectionIdToRemove: collection1.id,
          ),
        ),
      ).thenAnswer(
        (_) => Future.value(
          [
            const UseCaseResult.failure(
              CollectionUseCaseError.tryingToRemoveDefaultCollection,
              null,
            )
          ],
        ),
      );

      when(collectionErrorsEnumMapper.mapEnumToString(
        CollectionUseCaseError.tryingToRemoveDefaultCollection,
      )).thenReturn(Strings.errorMsgTryingToRemoveDefaultCollection);
    },
    act: (manager) => manager.removeCollection(
      collectionIdToRemove: collection1.id,
    ),
    expect: () => [
      //default one, emitted when manager created
      populatedState,
      populatedState.copyWith(
          errorMsg: Strings.errorMsgTryingToRemoveDefaultCollection),
    ],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
        removeCollectionUseCase.call(
          RemoveCollectionUseCaseParam(
            collectionIdToRemove: collection1.id,
          ),
        ),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(removeCollectionUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );
}
