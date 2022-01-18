import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late CreateOrGetDefaultCollectionUseCase createDefaultCollectionUseCase;
  const String defaultCollectionName = 'Read Later';
  final collection = Collection(
      id: Collection.readLaterId, name: defaultCollectionName.trim(), index: 0);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    createDefaultCollectionUseCase =
        CreateOrGetDefaultCollectionUseCase(collectionsRepository);
  });

  group('Rename collection use case', () {
    useCaseTest(
      'WHEN the default collection already exists THEN throw error',
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
          throwsA(
            CollectionUseCaseError.tryingToCreateAgainDefaultCollection,
          ),
        ),
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
