import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/topic/handle_topic_shown_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleTopicsShownUseCase handleTopicsShownUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleTopicsShownUseCase = HandleTopicsShownUseCase(appStatusRepository);

  final initialAppStatus = AppStatus.initial();

  const initialTopics = InLineCard.initial(CardType.topics);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  late AppStatus updatedAppStatus;

  useCaseTest(
    'WHEN called THEN update the topics object into the db with increased number of time shown',
    setUp: () {
      final updatedTopics = initialTopics.copyWith(
          numberOfTimesShown: initialTopics.numberOfTimesShown + 1);

      updatedAppStatus = initialAppStatus.copyWith(
          cta: initialAppStatus.cta.copyWith(
        topics: updatedTopics,
      ));
    },
    build: () => handleTopicsShownUseCase,
    input: [none],
    verify: (_) {
      verify(appStatusRepository.save(updatedAppStatus)).called(1);
    },
    expect: [
      useCaseSuccess(none),
    ],
  );
}
