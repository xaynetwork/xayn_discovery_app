import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_collection_card_data_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

import 'collection_card_manager_test.mocks.dart';

@GenerateMocks([GetCollectionCardDataUseCase, CollectionErrorsEnumMapper])
void main() {
  late MockGetCollectionCardDataUseCase getcollectionCardDataUseCase;
  late MockCollectionErrorsEnumMapper collectionErrorsEnumMapper;
  late CollectionCardManager collectionCardManager;
  late CollectionCardState initialState;
  late CollectionCardState populatedState;
  late UniqueId collectionId;
  late int numOfItems;
  late Uint8List image;

  setUp(() {
    getcollectionCardDataUseCase = MockGetCollectionCardDataUseCase();
    collectionErrorsEnumMapper = MockCollectionErrorsEnumMapper();
    collectionCardManager = CollectionCardManager(
      getcollectionCardDataUseCase,
      collectionErrorsEnumMapper,
    );
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
    setUp: () =>
        when(getcollectionCardDataUseCase.call(collectionId)).thenAnswer(
      (_) => Future.value(
        [
          UseCaseResult.success(
            GetCollectionCardDataUseCaseOut(
              numOfItems: numOfItems,
              image: image,
            ),
          )
        ],
      ),
    ),
    act: (manager) => manager.retrieveCollectionCardInfo(collectionId),
    verify: (manager) {
      verify(getcollectionCardDataUseCase.call(collectionId)).called(1);
      verifyNoMoreInteractions(getcollectionCardDataUseCase);
    },
    expect: () => [
      initialState,
      populatedState,
    ],
  );

  blocTest<CollectionCardManager, CollectionCardState>(
    'WHEN getCollectionCardDataUseCase returns a failure output THEN emit current state with error message ',
    build: () => collectionCardManager,
    setUp: () {
      when(getcollectionCardDataUseCase.call(collectionId)).thenAnswer(
        (_) => Future.value(
          [
            const UseCaseResult.failure(
              CollectionUseCaseError
                  .tryingToGetCardDataForNotExistingCollection,
              null,
            )
          ],
        ),
      );
      when(
        collectionErrorsEnumMapper.mapEnumToString(
          CollectionUseCaseError.tryingToGetCardDataForNotExistingCollection,
        ),
      ).thenReturn(Strings.errorMsgTryingToGetCardDataForNotExistingCollection);
    },
    act: (manager) => manager.retrieveCollectionCardInfo(collectionId),
    verify: (manager) {
      verify(getcollectionCardDataUseCase.call(collectionId)).called(1);
      verifyNoMoreInteractions(getcollectionCardDataUseCase);
    },
    expect: () => [
      initialState,
      initialState.copyWith(
        errorMsg: Strings.errorMsgTryingToGetCardDataForNotExistingCollection,
      ),
    ],
  );
}
