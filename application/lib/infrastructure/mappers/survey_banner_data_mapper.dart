import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@singleton
class SurveyBannerMapper extends Mapper<SurveyBanner, DbEntityMap> {
  const SurveyBannerMapper();

  @override
  DbEntityMap map(SurveyBanner input) => {
        SurveyBannerFields.numberOfTimesShown: input.numberOfTimesShown,
        SurveyBannerFields.hasSurveyBannerBeenClicked:
            input.hasSurveyBannerBeenClicked,
      };
}

@singleton
class DbEntityMapToSurveyBannerMapper
    extends Mapper<DbEntityMap?, SurveyBanner> {
  const DbEntityMapToSurveyBannerMapper();

  @override
  SurveyBanner map(Map? input) {
    if (input == null) return const SurveyBanner.initial();

    final numberOfTimesShown =
        input[SurveyBannerFields.numberOfTimesShown] ?? 0;
    final hasSurveyBannerBeenClicked =
        input[SurveyBannerFields.hasSurveyBannerBeenClicked] ?? false;

    return SurveyBanner(
      numberOfTimesShown: numberOfTimesShown,
      hasSurveyBannerBeenClicked: hasSurveyBannerBeenClicked,
    );
  }
}

abstract class SurveyBannerFields {
  SurveyBannerFields._();

  static const numberOfTimesShown = 0;
  static const hasSurveyBannerBeenClicked = 1;
}
