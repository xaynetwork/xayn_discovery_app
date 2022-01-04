import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_exception.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_default_collection_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late CreateDefaultCollectionUseCase createDefaultCollectionUseCase;
  const String defaultCollectionName = 'Read Later';
  final collection = Collection(
      id: Collection.readLaterId, name: defaultCollectionName, index: 0);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    createDefaultCollectionUseCase =
        CreateDefaultCollectionUseCase(collectionsRepository);
  });

  group('Rename collection use case', () {
    useCaseTest(
      'WHEN the default collection already exists THEN throw an exception',
      setUp: () =>
          when(collectionsRepository.getAll()).thenReturn([collection]),
      build: () => createDefaultCollectionUseCase,
      input: [defaultCollectionName],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getAll(),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(const TypeMatcher<CollectionUseCaseException>()),
        )
      ],
    );

    useCaseTest(
      'WHEN the default collection doesn\'t exist THEN create the collection, save it and return it',
      setUp: () => when(collectionsRepository.getAll()).thenReturn([]),
      build: () => createDefaultCollectionUseCase,
      input: [defaultCollectionName],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getAll(),
          collectionsRepository.save(collection),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [useCaseSuccess(collection)],
    );
  });
}
