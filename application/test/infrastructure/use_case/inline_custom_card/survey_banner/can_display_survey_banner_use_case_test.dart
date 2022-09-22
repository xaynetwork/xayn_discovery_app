import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/can_display_survey_banner_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockAppStatusRepository appStatusRepository;
  late MockFeatureManager featureManager;
  late CanDisplaySurveyBannerUseCase canDisplaySurveyBannerUseCase;

  getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
  appStatusRepository = MockAppStatusRepository();
  featureManager = MockFeatureManager();
  canDisplaySurveyBannerUseCase = CanDisplaySurveyBannerUseCase(
    getSubscriptionStatusUseCase,
    appStatusRepository,
    featureManager,
  );

  final initialAppStatus = AppStatus.initial();

  final appStatusFirstSession = initialAppStatus.copyWith(numberOfSessions: 1);

  final appStatusSecondSession = initialAppStatus.copyWith(numberOfSessions: 2);

  const initialSurveyBanner = InLineCard.initial(CardType.survey);

  final surveyBannerShownOnce =
      initialSurveyBanner.copyWith(numberOfTimesShown: 1);

  final surveyBannerShownTwice =
      initialSurveyBanner.copyWith(numberOfTimesShown: 2);

  final surveyBannerClicked = surveyBannerShownOnce.clicked(sessionNumber: 2);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'CanDisplaySurveyBannerUseCase',
    () {
      group(
        'Feature flag ENABLED',
        () {
          group(
            'Subscribed user',
            () {
              useCaseTest(
                'WHEN survey has been shown already twice THEN return false',
                setUp: () {
                  when(featureManager.isPromptSurveyEnabled).thenReturn(true);
                  when(getSubscriptionStatusUseCase.singleOutput(none))
                      .thenAnswer((_) async => SubscriptionStatus.initial()
                          .copyWith(isBetaUser: true));
                  when(appStatusRepository.appStatus).thenReturn(
                    initialAppStatus.copyWith(
                      cta: initialAppStatus.cta
                          .copyWith(surveyBanner: surveyBannerShownTwice),
                    ),
                  );
                },
                build: () => canDisplaySurveyBannerUseCase,
                input: [none],
                expect: [
                  useCaseSuccess(false),
                ],
              );

              useCaseTest(
                'WHEN survey has been clicked already THEN return false',
                setUp: () {
                  when(featureManager.isPromptSurveyEnabled).thenReturn(true);
                  when(getSubscriptionStatusUseCase.singleOutput(none))
                      .thenAnswer((_) async => SubscriptionStatus.initial()
                          .copyWith(isBetaUser: true));
                  when(appStatusRepository.appStatus).thenReturn(
                    initialAppStatus.copyWith(
                      cta: initialAppStatus.cta.copyWith(
                        surveyBanner: surveyBannerClicked,
                      ),
                    ),
                  );
                },
                build: () => canDisplaySurveyBannerUseCase,
                input: [none],
                expect: [
                  useCaseSuccess(false),
                ],
              );

              useCaseTest(
                'WHEN survey has been shown but NOT clicked and the session delta threshold has NOT been reached yet THEN return false',
                setUp: () {
                  when(featureManager.isPromptSurveyEnabled).thenReturn(true);
                  when(getSubscriptionStatusUseCase.singleOutput(none))
                      .thenAnswer((_) async => SubscriptionStatus.initial()
                          .copyWith(isBetaUser: true));
                  when(appStatusRepository.appStatus).thenReturn(
                    appStatusFirstSession.copyWith(
                      cta: initialAppStatus.cta.copyWith(
                        surveyBanner: surveyBannerShownOnce,
                      ),
                    ),
                  );
                },
                build: () => canDisplaySurveyBannerUseCase,
                input: [none],
                expect: [
                  useCaseSuccess(false),
                ],
              );

              useCaseTest(
                'WHEN survey has been shown but NOT clicked and the session delta threshold has been reached THEN return true',
                setUp: () {
                  when(featureManager.isPromptSurveyEnabled).thenReturn(true);
                  when(getSubscriptionStatusUseCase.singleOutput(none))
                      .thenAnswer((_) async => SubscriptionStatus.initial()
                          .copyWith(isBetaUser: true));
                  when(appStatusRepository.appStatus).thenReturn(
                    appStatusSecondSession.copyWith(
                      cta: initialAppStatus.cta.copyWith(
                        surveyBanner: surveyBannerShownOnce,
                      ),
                    ),
                  );
                },
                build: () => canDisplaySurveyBannerUseCase,
                input: [none],
                expect: [
                  useCaseSuccess(true),
                ],
              );
            },
          );

          group(
            'Not subscribed user',
            () {
              setUp(() {
                when(getSubscriptionStatusUseCase.singleOutput(none))
                    .thenAnswer((_) async => SubscriptionStatus.initial());
              });

              useCaseTest(
                'WHEN survey has not been shown yet THEN return true',
                setUp: () {
                  when(featureManager.isPromptSurveyEnabled).thenReturn(true);
                  when(getSubscriptionStatusUseCase.singleOutput(none))
                      .thenAnswer((_) async => SubscriptionStatus.initial());
                  when(appStatusRepository.appStatus)
                      .thenReturn(initialAppStatus);
                },
                build: () => canDisplaySurveyBannerUseCase,
                input: [none],
                expect: [
                  useCaseSuccess(true),
                ],
              );

              useCaseTest(
                'WHEN survey has been shown already THEN return false',
                setUp: () {
                  when(featureManager.isPromptSurveyEnabled).thenReturn(true);
                  when(getSubscriptionStatusUseCase.singleOutput(none))
                      .thenAnswer((_) async => SubscriptionStatus.initial());
                  final cta = initialAppStatus.cta
                      .copyWith(surveyBanner: surveyBannerShownOnce);
                  when(appStatusRepository.appStatus).thenReturn(
                    initialAppStatus.copyWith(
                      cta: cta,
                    ),
                  );
                },
                build: () => canDisplaySurveyBannerUseCase,
                input: [none],
                expect: [
                  useCaseSuccess(false),
                ],
              );
            },
          );
        },
      );
      group(
        'Feature flag DISABLED',
        () {
          useCaseTest(
            'WHEN calling the use case with flag disabled THEN dont update the user interactions repository',
            setUp: () {
              when(featureManager.isPromptSurveyEnabled).thenReturn(false);
            },
            build: () => canDisplaySurveyBannerUseCase,
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
