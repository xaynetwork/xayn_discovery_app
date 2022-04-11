import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late RenameCollectionUseCase renameCollectionUseCase;
  final defaultCollection = Collection.readLater(name: 'readLater');
  final collection =
      Collection(id: UniqueId(), name: 'Collection name', index: 1);
  const String newCollectionName = 'New collection name';

  final updatedCollection = collection.copyWith(name: newCollectionName.trim());

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    renameCollectionUseCase = RenameCollectionUseCase(collectionsRepository);

    when(collectionsRepository.isCollectionNameNotValid(newCollectionName))
        .thenReturn(false);

    when(collectionsRepository.isCollectionNameUsed(newCollectionName))
        .thenReturn(false);

    when(collectionsRepository.getById(Collection.readLaterId))
        .thenReturn(defaultCollection);

    when(collectionsRepository.isCollectionNameNotValid(defaultCollection.name))
        .thenReturn(false);

    when(collectionsRepository.isCollectionNameUsed(defaultCollection.name))
        .thenReturn(true);
  });

  group('Rename collection use case', () {
    useCaseTest(
      'WHEN the given name corresponds to a collection name that already exists THEN throw error',
      setUp: () =>
          when(collectionsRepository.isCollectionNameUsed(newCollectionName))
              .thenReturn(true),
      build: () => renameCollectionUseCase,
      input: [
        const RenameCollectionUseCaseParam(
            collectionId: Collection.readLaterId, newName: newCollectionName)
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.isCollectionNameNotValid(newCollectionName),
          collectionsRepository.getById(defaultCollection.id),
          collectionsRepository.isCollectionNameUsed(newCollectionName),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(
            CollectionUseCaseError.tryingToRenameCollectionUsingExistingName,
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN the given id corresponds to a collection that doesn\'t exist THEN yield failure output with proper enum value',
      setUp: () => when(collectionsRepository.getById(any)).thenReturn(null),
      build: () => renameCollectionUseCase,
      input: [
        RenameCollectionUseCaseParam(
            collectionId: collection.id, newName: newCollectionName)
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.isCollectionNameNotValid(newCollectionName),
          collectionsRepository.getById(collection.id),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(
            CollectionUseCaseError.tryingToRenameNotExistingCollection,
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN the given id corresponds to a collection that exists THEN rename the collection with the new name and return it',
      setUp: () =>
          when(collectionsRepository.getById(any)).thenReturn(collection),
      build: () => renameCollectionUseCase,
      input: [
        RenameCollectionUseCaseParam(
            collectionId: collection.id, newName: newCollectionName)
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.isCollectionNameNotValid(newCollectionName),
          collectionsRepository.getById(collection.id),
          collectionsRepository.isCollectionNameUsed(newCollectionName),
          collectionsRepository.save(updatedCollection),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(
          updatedCollection,
        )
      ],
    );
    useCaseTest(
      'WHEN the given id corresponds to a collection that exists THEN yield the collection',
      build: () => renameCollectionUseCase,
      input: [
        RenameCollectionUseCaseParam(
            collectionId: defaultCollection.id, newName: defaultCollection.name)
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository
              .isCollectionNameNotValid(defaultCollection.name),
          collectionsRepository.getById(defaultCollection.id),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(
          defaultCollection,
        ),
      ],
    );
  });
}
