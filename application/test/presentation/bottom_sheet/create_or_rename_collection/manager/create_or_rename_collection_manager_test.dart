import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/collection_renamed_event.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/manager/create_or_rename_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/manager/create_or_rename_collection_state.dart';

import '../../../../test_utils/utils.dart';

void main() {
  late MockCreateCollectionUseCase createCollectionUseCase;
  late MockRenameCollectionUseCase renameCollectionUseCase;
  late MockCollectionErrorsEnumMapper collectionErrorsEnumMapper;
  late MockSendAnalyticsUseCase sendAnalyticsUseCase;
  late CreateOrRenameCollectionState populatedState;
  late CreateOrRenameCollectionManager createOrRenameCollectionManager;

  final collection = Collection(
    id: UniqueId(),
    name: 'Collection test',
    index: 2,
  );

  final renamedCollection = collection.copyWith(name: 'Renamed collection');

  setUp(() {
    createCollectionUseCase = MockCreateCollectionUseCase();
    renameCollectionUseCase = MockRenameCollectionUseCase();
    collectionErrorsEnumMapper = MockCollectionErrorsEnumMapper();
    sendAnalyticsUseCase = MockSendAnalyticsUseCase();
    populatedState = CreateOrRenameCollectionState.populateCollectionName('');

    when(createCollectionUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(createCollectionUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(collection));

    when(renameCollectionUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(renameCollectionUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(renamedCollection));

    createOrRenameCollectionManager = CreateOrRenameCollectionManager(
      createCollectionUseCase,
      collectionErrorsEnumMapper,
      renameCollectionUseCase,
      sendAnalyticsUseCase,
    );
  });

  blocTest(
    'WHEN manager is create THEN the transform method of createCollectionUseCase and renameCollectionUseCase is called because of the usage of pipe ',
    build: () => createOrRenameCollectionManager,
    verify: (manager) {
      verifyInOrder([
        createCollectionUseCase.transform(any),
        renameCollectionUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(createCollectionUseCase);
      verifyNoMoreInteractions(renameCollectionUseCase);
    },
  );

  blocTest(
    'WHEN updateCollectionName is called THEN update correctly the state ',
    build: () => createOrRenameCollectionManager,
    act: (manager) {
      createOrRenameCollectionManager.updateCollectionName(collection.name);
    },
    verify: (manager) {
      verifyInOrder([
        createCollectionUseCase.transform(any),
        renameCollectionUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(createCollectionUseCase);
      verifyNoMoreInteractions(renameCollectionUseCase);
    },
    expect: () => [
      populatedState,
      populatedState.copyWith(
        collectionName: collection.name,
      )
    ],
  );

  blocTest(
    'WHEN createCollection is called THEN call createCollectionUseCase and update correctly the state ',
    build: () => createOrRenameCollectionManager,
    act: (manager) {
      createOrRenameCollectionManager.updateCollectionName(collection.name);
      createOrRenameCollectionManager.createCollection();
    },
    verify: (manager) {
      verifyInOrder([
        createCollectionUseCase.transform(any),
        renameCollectionUseCase.transform(any),
        createCollectionUseCase.transaction(any),
      ]);
      verifyNoMoreInteractions(createCollectionUseCase);
      verifyNoMoreInteractions(renameCollectionUseCase);
    },
    expect: () => [
      populatedState,
      populatedState.copyWith(
        collectionName: collection.name,
      ),
      populatedState.copyWith(newCollection: collection),
    ],
  );

  blocTest(
    'WHEN renameCollection is called THEN call renameCollectionUseCase and update correctly the state ',
    build: () => createOrRenameCollectionManager,
    setUp: () {
      when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
            UseCaseResult.success(
              CollectionRenamedEvent(),
            )
          ]);
    },
    act: (manager) {
      createOrRenameCollectionManager
          .updateCollectionName(renamedCollection.name);
      createOrRenameCollectionManager.renameCollection(collection.id);
    },
    verify: (manager) {
      verifyInOrder([
        createCollectionUseCase.transform(any),
        renameCollectionUseCase.transform(any),
        sendAnalyticsUseCase.call(any),
        renameCollectionUseCase.transaction(any),
      ]);
      verifyNoMoreInteractions(createCollectionUseCase);
      verifyNoMoreInteractions(renameCollectionUseCase);
      verifyNoMoreInteractions(sendAnalyticsUseCase);
    },
    expect: () => [
      populatedState,
      populatedState.copyWith(
        collectionName: renamedCollection.name,
      ),
      populatedState.copyWith(newCollection: renamedCollection),
    ],
  );
}
