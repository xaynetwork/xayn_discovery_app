import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/survey_banner/handle_survey_banner_shown_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleSurveyBannerShownUseCase handleSurveyBannerShownUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleSurveyBannerShownUseCase =
      HandleSurveyBannerShownUseCase(appStatusRepository);

  final initialAppStatus = AppStatus.initial();

  const initialSurveyBanner = InLineCard.initial(CardType.survey);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  late AppStatus updatedAppStatus;

  useCaseTest(
    'WHEN called THEN update the survey banner object into the db with increased number of time shown',
    setUp: () {
      final updatedSurveyBanner = initialSurveyBanner.copyWith(
          numberOfTimesShown: initialSurveyBanner.numberOfTimesShown + 1);

      updatedAppStatus = initialAppStatus.copyWith(
          cta: CTA(
        surveyBanner: updatedSurveyBanner,
      ));
    },
    build: () => handleSurveyBannerShownUseCase,
    input: [none],
    verify: (_) {
      verify(appStatusRepository.save(updatedAppStatus)).called(1);
    },
    expect: [
      useCaseSuccess(none),
    ],
  );
}
