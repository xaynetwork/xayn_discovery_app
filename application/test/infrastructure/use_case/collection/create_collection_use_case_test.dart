import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';

import 'create_collection_use_case_test.mocks.dart';

@GenerateMocks([CollectionsRepository, UniqueIdHandler])
void main() {
  late MockCollectionsRepository collectionsRepository;
  late MockUniqueIdHandler uniqueIdHandler;
  late CreateCollectionUseCase createCollectionUseCase;
  const String collectionName = 'Collection name';
  final collectionId = UniqueId();
  const int lastCollectionIndex = 1;
  final createdCollection = Collection(
      id: collectionId, name: collectionName, index: lastCollectionIndex + 1);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    uniqueIdHandler = MockUniqueIdHandler();
    createCollectionUseCase =
        CreateCollectionUseCase(collectionsRepository, uniqueIdHandler);
  });

  group('Create collection use case', () {
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
          collectionsRepository.getLastCollectionIndex(),
          uniqueIdHandler.generateUniqueId(),
          collectionsRepository.collection = createdCollection,
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [useCaseSuccess(createdCollection)],
    );
  });
}
