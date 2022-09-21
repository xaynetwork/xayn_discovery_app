import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/survey_banner/handle_survey_banner_clicked_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockUrlOpener urlOpener;
  late HandleSurveyBannerClickedUseCase handleSurveyBannerClickedUseCase;

  appStatusRepository = MockAppStatusRepository();
  getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
  urlOpener = MockUrlOpener();
  handleSurveyBannerClickedUseCase = HandleSurveyBannerClickedUseCase(
    appStatusRepository,
    urlOpener,
    getSubscriptionStatusUseCase,
  );

  final initialAppStatus = AppStatus.initial();

  const initialSurveyBanner = InLineCard.initial(CardType.survey);

  final clickedSurveyBanner =
      initialSurveyBanner.copyWith(hasSurveyBannerBeenClicked: true);

  final appStatusSurveyBannerClicked = initialAppStatus.copyWith(
    cta: CTA(
      surveyBanner: clickedSurveyBanner,
    ),
  );

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'WHEN user is subscribed',
    () {
      useCaseTest(
        'WHEN use case is called THEN update the survey banner object into the db with clicked flag set to true and open the survey url for subscribed user',
        setUp: () {
          when(getSubscriptionStatusUseCase.singleOutput(none)).thenAnswer(
              (_) async =>
                  SubscriptionStatus.initial().copyWith(isBetaUser: true));
        },
        build: () => handleSurveyBannerClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusSurveyBannerClicked))
              .called(1);
          verify(urlOpener.openUrl(subscribedUserSurveyUrl)).called(1);
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
        'WHEN use case is called THEN update the survey banner object into the db with clicked flag set to true and open the survey url for not subscribed user',
        setUp: () {
          when(getSubscriptionStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => SubscriptionStatus.initial());
        },
        build: () => handleSurveyBannerClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusSurveyBannerClicked))
              .called(1);
          verify(urlOpener.openUrl(notSubscribedUserSurveyUrl)).called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );
}
