import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner_data.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@singleton
class SurveyBannerDataMapper extends Mapper<SurveyBannerData, DbEntityMap> {
  const SurveyBannerDataMapper();

  @override
  DbEntityMap map(SurveyBannerData input) => {
        SurveyBannerDataFields.numberOfTimesShown: input.numberOfTimesShown,
        SurveyBannerDataFields.hasSurveyBannerBeenClicked:
            input.hasSurveyBannerBeenClicked,
      };
}

@singleton
class DbEntityMapToSurveyBannerDataMapper
    extends Mapper<DbEntityMap?, SurveyBannerData> {
  const DbEntityMapToSurveyBannerDataMapper();

  @override
  SurveyBannerData map(Map? input) {
    if (input == null) return const SurveyBannerData.initial();

    final numberOfTimesShown =
        input[SurveyBannerDataFields.numberOfTimesShown] ?? 0;
    final hasSurveyBannerBeenClicked =
        input[SurveyBannerDataFields.hasSurveyBannerBeenClicked] ?? false;

    return SurveyBannerData(
      numberOfTimesShown: numberOfTimesShown,
      hasSurveyBannerBeenClicked: hasSurveyBannerBeenClicked,
    );
  }
}

abstract class SurveyBannerDataFields {
  SurveyBannerDataFields._();

  static const numberOfTimesShown = 0;
  static const hasSurveyBannerBeenClicked = 1;
}
