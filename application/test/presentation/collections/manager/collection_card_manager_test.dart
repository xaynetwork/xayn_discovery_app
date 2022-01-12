import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_exception.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_collection_card_data_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';

import 'collection_card_manager_test.mocks.dart';

@GenerateMocks([GetCollectionCardDataUseCase])
void main() {
  late MockGetCollectionCardDataUseCase getcollectionCardDataUseCase;
  late CollectionCardManager collectionCardManager;
  late CollectionCardState initialState;
  late CollectionCardState populatedState;
  late UniqueId collectionId;
  late int numOfItems;
  late Uint8List image;

  setUp(() {
    getcollectionCardDataUseCase = MockGetCollectionCardDataUseCase();
    collectionCardManager = CollectionCardManager(getcollectionCardDataUseCase);
    collectionId = UniqueId();
    numOfItems = 4;
    image = Uint8List.fromList([1, 2, 3]);
    initialState = CollectionCardState.initial();
    populatedState = CollectionCardState.populated(
      numOfItems: numOfItems,
      image: image,
    );
  });

  blocTest<CollectionCardManager, CollectionCardState>(
    'WHEN manager is created THEN emit initial state ',
    build: () => collectionCardManager,
    expect: () => [
      initialState,
    ],
  );

  blocTest<CollectionCardManager, CollectionCardState>(
    'WHEN retrieveCollectionCardInfo method is called THEN call getCollectionCardDataUseCase and emit state with values ',
    build: () => collectionCardManager,
    setUp: () => when(getcollectionCardDataUseCase.singleOutput(collectionId))
        .thenAnswer(
      (realInvocation) => Future.value(
        GetCollectionCardDataUseCaseOut(
          numOfItems: numOfItems,
          image: image,
        ),
      ),
    ),
    act: (manager) => manager.retrieveCollectionCardInfo(collectionId),
    verify: (manager) {
      verify(getcollectionCardDataUseCase.singleOutput(collectionId)).called(1);
      verifyNoMoreInteractions(getcollectionCardDataUseCase);
    },
    expect: () => [
      initialState,
      populatedState,
    ],
  );

  blocTest<CollectionCardManager, CollectionCardState>(
    'WHEN getCollectionCardDataUseCase throws an exception THEN call emit current state with error message ',
    build: () => collectionCardManager,
    setUp: () => when(getcollectionCardDataUseCase.singleOutput(collectionId))
        .thenAnswer(
      (realInvocation) => Future.error(
        GetCollectionCardDataUseCaseException(
          errorMsgCollectionDoesntExist,
        ),
      ),
    ),
    act: (manager) => manager.retrieveCollectionCardInfo(collectionId),
    verify: (manager) {
      verify(getcollectionCardDataUseCase.singleOutput(collectionId)).called(1);
      verifyNoMoreInteractions(getcollectionCardDataUseCase);
    },
    expect: () => [
      initialState,
      initialState.copyWith(
        errorMsg: errorMsgCollectionDoesntExist,
      ),
    ],
  );
}
