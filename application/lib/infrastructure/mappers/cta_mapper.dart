import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/cta/cta.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/inline_card_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@singleton
class CTAMapToDbEntityMapper extends Mapper<CTA, DbEntityMap> {
  final InLineCardMapper _inlineCardMapper;

  const CTAMapToDbEntityMapper(
    this._inlineCardMapper,
  );

  @override
  DbEntityMap map(CTA input) => {
        CTAFields.surveyBanner: _inlineCardMapper.map(input.surveyBanner),
        CTAFields.sourceSelection: _inlineCardMapper.map(input.sourceSelection),
        CTAFields.countrySelection:
            _inlineCardMapper.map(input.countrySelection),
      };
}

@singleton
class DbEntityMapToCTAMapper extends Mapper<DbEntityMap?, CTA> {
  final DbEntityMapToSurveyInLineCardMapper _mapToSurveyBannerMapper;
  final DbEntityMapToCountrySelectionInLineCardMapper
      _mapToCountrySelectionMapper;
  final DbEntityMapToSourceSelectionInLineCardMapper
      _mapToSourceSelectionMapper;

  const DbEntityMapToCTAMapper(
    this._mapToSurveyBannerMapper,
    this._mapToCountrySelectionMapper,
    this._mapToSourceSelectionMapper,
  );

  @override
  CTA map(Map? input) {
    if (input == null) return const CTA.initial();

    return CTA(
      surveyBanner: _mapToSurveyBannerMapper.map(input[CTAFields.surveyBanner]),
      sourceSelection:
          _mapToSourceSelectionMapper.map(input[CTAFields.sourceSelection]),
      countrySelection:
          _mapToCountrySelectionMapper.map(input[CTAFields.countrySelection]),
    );
  }
}

abstract class CTAFields {
  CTAFields._();

  static const surveyBanner = 0;
  static const sourceSelection = 1;
  static const countrySelection = 2;
}
