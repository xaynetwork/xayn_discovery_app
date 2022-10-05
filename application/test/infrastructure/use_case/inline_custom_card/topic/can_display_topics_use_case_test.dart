import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/topic/can_display_topic_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late MockFeatureManager featureManager;
  late CanDisplayTopicsUseCase canDisplayTopicsUseCase;

  appStatusRepository = MockAppStatusRepository();
  featureManager = MockFeatureManager();
  canDisplayTopicsUseCase = CanDisplayTopicsUseCase(
    appStatusRepository,
    featureManager,
  );

  final initialAppStatus = AppStatus.initial();

  const initialTopics = InLineCard.initial(CardType.topics);

  final topicsShownOnce = initialTopics.copyWith(numberOfTimesShown: 1);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'CanDisplayTopicsUseCase',
    () {
      group(
        'Feature flag ENABLED',
        () {
          useCaseTest(
            'WHEN topics has been shown THEN return false',
            setUp: () {
              when(featureManager.isTopicsEnabled).thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus.copyWith(
                  cta: initialAppStatus.cta.copyWith(topics: topicsShownOnce),
                ),
              );
            },
            build: () => canDisplayTopicsUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );

          useCaseTest(
            'WHEN topics has not been shown THEN return true',
            setUp: () {
              when(featureManager.isTopicsEnabled).thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus,
              );
            },
            build: () => canDisplayTopicsUseCase,
            input: [none],
            expect: [
              useCaseSuccess(true),
            ],
          );
        },
      );
      group(
        'Feature flag DISABLED',
        () {
          useCaseTest(
            'WHEN calling the use case with flag disabled THEN return false',
            setUp: () {
              when(featureManager.isTopicsEnabled).thenReturn(false);
            },
            build: () => canDisplayTopicsUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );
        },
      );
    },
  );
}
