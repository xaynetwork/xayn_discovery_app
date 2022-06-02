import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/survey_banner_data_mapper.dart';

@singleton
class CTAMapToDbEntityMapper extends Mapper<CTA, DbEntityMap> {
  final SurveyBannerDataMapper _surveyBannerDataMapper;

  const CTAMapToDbEntityMapper(
    this._surveyBannerDataMapper,
  );

  @override
  DbEntityMap map(CTA input) => {
        CTAFields.surveyBannerData:
            _surveyBannerDataMapper.map(input.surveyBannerData),
      };
}

@singleton
class DbEntityMapToCTAMapper extends Mapper<DbEntityMap?, CTA> {
  final DbEntityMapToSurveyBannerDataMapper _mapToSurveyBannerDataMapper;
  const DbEntityMapToCTAMapper(
    this._mapToSurveyBannerDataMapper,
  );

  @override
  CTA map(Map? input) {
    if (input == null) return const CTA.initial();

    return CTA(
      surveyBannerData:
          _mapToSurveyBannerDataMapper.map(input[CTAFields.surveyBannerData]),
    );
  }
}

abstract class CTAFields {
  CTAFields._();

  static const surveyBannerData = 0;
}
