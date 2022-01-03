import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late GetAllCollectionsUseCase getAllCollectionsUseCase;
  final collection1 =
      Collection(id: UniqueId(), name: 'Collection1 name', index: 1);
  final collection2 =
      Collection(id: UniqueId(), name: 'Collection2 name', index: 2);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    getAllCollectionsUseCase = GetAllCollectionsUseCase(collectionsRepository);
  });

  group('Get all collections use case', () {
    useCaseTest(
      'WHEN called THEN get all the collections',
      setUp: () => when(collectionsRepository.getAll()).thenReturn(
        [collection1, collection2],
      ),
      build: () => getAllCollectionsUseCase,
      input: [none],
      verify: (_) {
        verify(collectionsRepository.getAll()).called(1);
      },
      expect: [
        useCaseSuccess(GetAllCollectionsUseCaseOut([
          collection1,
          collection2,
        ])),
      ],
    );
  });
}
