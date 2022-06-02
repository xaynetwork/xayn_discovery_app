import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner_data.dart';

@immutable
class CTA extends Equatable {
  final SurveyBannerData surveyBannerData;

  const CTA({required this.surveyBannerData});

  const CTA.initial() : surveyBannerData = const SurveyBannerData.initial();

  CTA copyWith({
    SurveyBannerData? surveyBannerData,
  }) =>
      CTA(
        surveyBannerData: surveyBannerData ?? this.surveyBannerData,
      );

  @override
  List<Object?> get props => [
        surveyBannerData,
      ];
}
