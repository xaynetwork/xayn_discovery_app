import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collection_card_data_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockListenCollectionCardDataUseCase getcollectionCardDataUseCase;
  late CollectionErrorsEnumMapper collectionErrorsEnumMapper;
  late CollectionCardManager collectionCardManager;
  late CollectionCardState initialState;
  late CollectionCardState populatedState;
  late UniqueId collectionId;
  late int numOfItems;
  late Uint8List image;

  setUp(() {
    getcollectionCardDataUseCase = MockListenCollectionCardDataUseCase();
    when(getcollectionCardDataUseCase.transform(any)).thenAnswer(
      (realInvocation) => realInvocation.positionalArguments.first,
    );
    when(getcollectionCardDataUseCase.transaction(any)).thenAnswer(
      (realInvocation) => Stream.value(GetCollectionCardDataUseCaseOut(
        numOfItems: numOfItems,
        image: image,
      )),
    );
    collectionErrorsEnumMapper = CollectionErrorsEnumMapper();
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
    setUp: () => when(getcollectionCardDataUseCase.transaction(collectionId))
        .thenAnswer((_) => Stream.value(
              GetCollectionCardDataUseCaseOut(
                numOfItems: numOfItems,
                image: image,
              ),
            )),
    act: (manager) => manager.retrieveCollectionCardInfo(collectionId),
    expect: () => [
      initialState,
      populatedState,
    ],
  );

  blocTest<CollectionCardManager, CollectionCardState>(
    'WHEN getCollectionCardDataUseCase returns a failure output THEN emit current state with error message ',
    build: () => collectionCardManager,
    setUp: () {
      when(getcollectionCardDataUseCase.transaction(collectionId)).thenAnswer(
          (_) => Stream.error(CollectionUseCaseError
              .tryingToGetCardDataForNotExistingCollection));
    },
    act: (manager) => manager.retrieveCollectionCardInfo(collectionId),
    expect: () => [
      initialState,
      initialState.copyWith(
        errorMsg: R.strings.errorMsgCollectionDoesntExist,
      ),
    ],
  );
}
