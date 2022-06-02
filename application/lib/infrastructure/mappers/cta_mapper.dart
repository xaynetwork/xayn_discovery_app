import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/survey_banner_data_mapper.dart';

@singleton
class CTAMapToDbEntityMapper extends Mapper<CTA, DbEntityMap> {
  final SurveyBannerMapper _surveyBannerMapper;

  const CTAMapToDbEntityMapper(
    this._surveyBannerMapper,
  );

  @override
  DbEntityMap map(CTA input) => {
        CTAFields.surveyBanner: _surveyBannerMapper.map(input.surveyBanner),
      };
}

@singleton
class DbEntityMapToCTAMapper extends Mapper<DbEntityMap?, CTA> {
  final DbEntityMapToSurveyBannerMapper _mapToSurveyBannerMapper;
  const DbEntityMapToCTAMapper(
    this._mapToSurveyBannerMapper,
  );

  @override
  CTA map(Map? input) {
    if (input == null) return const CTA.initial();

    return CTA(
      surveyBanner: _mapToSurveyBannerMapper.map(input[CTAFields.surveyBanner]),
    );
  }
}

abstract class CTAFields {
  CTAFields._();

  static const surveyBanner = 0;
}
