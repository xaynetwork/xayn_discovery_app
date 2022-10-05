import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/topic/handle_topic_card_clicked_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleTopicsClickedUseCase handleTopicsClickedUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleTopicsClickedUseCase = HandleTopicsClickedUseCase(
    appStatusRepository,
  );

  final initialAppStatus = AppStatus.initial();

  const initialTopics = InLineCard.initial(CardType.topics);

  final clickedTopics = initialTopics.copyWith(hasBeenClicked: true);

  final appStatusTopicsClicked = initialAppStatus.copyWith(
    cta: initialAppStatus.cta.copyWith(
      topics: clickedTopics,
    ),
  );

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'WHEN user is subscribed',
    () {
      useCaseTest(
        'WHEN use case is called THEN update the topics object into the db with clicked flag set to true',
        build: () => handleTopicsClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusTopicsClicked)).called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );

  group(
    'WHEN user is NOT subscribed',
    () {
      useCaseTest(
        'WHEN use case is called THEN update the topics into the db with clicked flag set to true',
        build: () => handleTopicsClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusTopicsClicked)).called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );
}
