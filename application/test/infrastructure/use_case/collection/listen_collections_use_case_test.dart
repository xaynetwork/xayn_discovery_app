import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late ListenCollectionsUseCase listenCollectionsUseCase;
  final collection1 =
      Collection(id: UniqueId(), name: 'Collection1 name', index: 1);
  final collection2 =
      Collection(id: UniqueId(), name: 'Collection2 name', index: 2);

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    listenCollectionsUseCase = ListenCollectionsUseCase(collectionsRepository);
  });

  group('Listen collections use case', () {
    useCaseTest(
      'WHEN repository emits an event THEN usecase emits the list of collections',
      setUp: () {
        when(collectionsRepository.watch()).thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              id: UniqueId(),
              newObject: collection1,
            ),
          ),
        );
        when(collectionsRepository.getAll())
            .thenReturn([collection1, collection2]);
      },
      build: () => listenCollectionsUseCase,
      input: [none],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.watch(),
          collectionsRepository.getAll(),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(
          ListenCollectionsUseCaseOut([collection1, collection2]),
        )
      ],
    );
  });
}
