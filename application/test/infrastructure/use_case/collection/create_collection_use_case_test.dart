import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late MockUniqueIdHandler uniqueIdHandler;
  late CreateCollectionUseCase createCollectionUseCase;
  const String collectionName = 'Collection name';
  final collectionId = UniqueId();
  const int lastCollectionIndex = 1;
  final createdCollection = Collection(
      id: collectionId,
      name: collectionName.trim(),
      index: lastCollectionIndex + 1);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    uniqueIdHandler = MockUniqueIdHandler();
    createCollectionUseCase =
        CreateCollectionUseCase(collectionsRepository, uniqueIdHandler);

    when(collectionsRepository.isCollectionNameNotValid(collectionName))
        .thenReturn(false);

    when(collectionsRepository.isCollectionNameUsed(collectionName))
        .thenReturn(false);
  });

  group('Create collection use case', () {
    useCaseTest(
      'WHEN the given name corresponds to a collection name that already exists THEN throw error',
      setUp: () =>
          when(collectionsRepository.isCollectionNameUsed(collectionName))
              .thenReturn(true),
      build: () => createCollectionUseCase,
      input: [
        collectionName,
      ],
      verify: (_) {
        verify(collectionsRepository.isCollectionNameNotValid(collectionName))
            .called(1);
        verify(collectionsRepository.isCollectionNameUsed(collectionName))
            .called(1);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(
            CollectionUseCaseError.tryingToCreateCollectionUsingExistingName,
          ),
        ),
      ],
    );
    useCaseTest(
      'WHEN given a name THEN create the collection, save it and return it',
      setUp: () {
        when(collectionsRepository.getLastCollectionIndex())
            .thenReturn(lastCollectionIndex);
        when(uniqueIdHandler.generateUniqueId()).thenReturn(collectionId);
      },
      build: () => createCollectionUseCase,
      input: [collectionName],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.isCollectionNameNotValid(collectionName),
          collectionsRepository.isCollectionNameUsed(collectionName),
          collectionsRepository.getLastCollectionIndex(),
          uniqueIdHandler.generateUniqueId(),
          collectionsRepository.save(createdCollection),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(
          createdCollection,
        ),
      ],
    );
  });
}
