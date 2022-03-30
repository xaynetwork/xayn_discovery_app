import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/create_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/rename_collection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/haptic_feedbacks/haptic_feedback_medium_use_case.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collections_screen_state.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';

import 'collections_screen_manager_test.mocks.dart';

@GenerateMocks([
  CreateCollectionUseCase,
  RemoveCollectionUseCase,
  RenameCollectionUseCase,
  ListenCollectionsUseCase,
  GetAllCollectionsUseCase,
  GetAllBookmarksUseCase,
  CollectionErrorsEnumMapper,
  CollectionsScreenNavActions,
  DateTimeHandler,
  HapticFeedbackMediumUseCase,
])
void main() {
  late MockListenCollectionsUseCase listenCollectionsUseCase;
  late MockGetAllCollectionsUseCase getAllCollectionsUseCase;
  late MockHapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  late MockCollectionsScreenNavActions collectionsScreenNavActions;
  late MockDateTimeHandler dateTimeHandler;
  late CollectionsScreenState populatedState;
  final timeStamp = DateTime.now();
  final collection1 =
      Collection(id: UniqueId(), name: 'Collection1 name', index: 0);
  final collection2 =
      Collection(id: UniqueId(), name: 'Collection2 name', index: 1);
  late CollectionsScreenManager collectionsScreenManager;

  void _mockManagerInitMethodCalls() {
    when(getAllCollectionsUseCase.singleOutput(none)).thenAnswer(
      (_) => Future.value(
        GetAllCollectionsUseCaseOut(
          [
            collection1,
            collection2,
          ],
        ),
      ),
    );

    when(listenCollectionsUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timeStamp);
  }

  Future<CollectionsScreenManager> createManager() async =>
      await CollectionsScreenManager.create(
        getAllCollectionsUseCase,
        listenCollectionsUseCase,
        hapticFeedbackMediumUseCase,
        collectionsScreenNavActions,
        dateTimeHandler,
      );

  setUp(() async {
    listenCollectionsUseCase = MockListenCollectionsUseCase();
    getAllCollectionsUseCase = MockGetAllCollectionsUseCase();
    hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
    collectionsScreenNavActions = MockCollectionsScreenNavActions();
    dateTimeHandler = MockDateTimeHandler();
    populatedState = CollectionsScreenState.populated(
      [collection1, collection2],
      timeStamp,
    );

    _mockManagerInitMethodCalls();
    collectionsScreenManager = await createManager();
  });

  blocTest<CollectionsScreenManager, CollectionsScreenState>(
    'WHEN manager is created THEN get values and emit CollectionsScreenStatePopulated ',
    build: () => collectionsScreenManager,
    expect: () => [
      populatedState,
    ],
    verify: (manager) {
      verifyInOrder([
        getAllCollectionsUseCase.singleOutput(none),
        listenCollectionsUseCase.transform(any),
      ]);
      verifyNoMoreInteractions(getAllCollectionsUseCase);
      verifyNoMoreInteractions(listenCollectionsUseCase);
    },
  );
}
