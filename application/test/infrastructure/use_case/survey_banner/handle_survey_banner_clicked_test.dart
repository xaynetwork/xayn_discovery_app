import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/survey_banner/handle_survey_banner_clicked_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleSurveyBannerClickedUseCase handleSurveyBannerClickedUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleSurveyBannerClickedUseCase =
      HandleSurveyBannerClickedUseCase(appStatusRepository);

  final initialAppStatus = AppStatus.initial();

  const initialSurveyBanner = SurveyBanner.initial();

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  late AppStatus updatedAppStatus;

  useCaseTest(
    'WHEN called THEN update the survey banner object into the db with clicked flag set to true',
    setUp: () {
      final updatedSurveyBanner =
          initialSurveyBanner.copyWith(hasSurveyBannerBeenClicked: true);

      updatedAppStatus = initialAppStatus.copyWith(
          cta: CTA(
        surveyBanner: updatedSurveyBanner,
      ));
    },
    build: () => handleSurveyBannerClickedUseCase,
    input: [none],
    verify: (_) {
      verify(appStatusRepository.save(updatedAppStatus)).called(1);
    },
    expect: [
      useCaseSuccess(none),
    ],
  );
}
