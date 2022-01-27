import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_or_get_default_collection_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late CreateOrGetDefaultCollectionUseCase createOrGetDefaultCollectionUseCase;
  const String defaultCollectionName = 'Read Later';
  final collection = Collection(
      id: Collection.readLaterId, name: defaultCollectionName.trim(), index: 0);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    createOrGetDefaultCollectionUseCase =
        CreateOrGetDefaultCollectionUseCase(collectionsRepository);
  });

  group('Create or get default collection use case', () {
    useCaseTest(
      'WHEN the default collection already exists THEN return it',
      setUp: () =>
          when(collectionsRepository.getAll()).thenReturn([collection]),
      build: () => createOrGetDefaultCollectionUseCase,
      input: [defaultCollectionName],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getAll(),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(collection),
      ],
    );

    useCaseTest(
      'WHEN the default collection does not exist THEN create it',
      setUp: () {
        when(collectionsRepository.getAll()).thenReturn([]);
        when(collectionsRepository.save(collection));
      },
      build: () => createOrGetDefaultCollectionUseCase,
      input: [defaultCollectionName],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getAll(),
          collectionsRepository.save(collection),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(collection),
      ],
    );
  });
}
