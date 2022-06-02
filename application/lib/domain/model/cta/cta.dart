import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/survey_banner/survey_banner.dart';

@immutable
class CTA extends Equatable {
  final SurveyBanner surveyBanner;

  const CTA({required this.surveyBanner});

  const CTA.initial() : surveyBanner = const SurveyBanner.initial();

  CTA copyWith({
    SurveyBanner? surveyBanner,
  }) =>
      CTA(
        surveyBanner: surveyBanner ?? this.surveyBanner,
      );

  @override
  List<Object?> get props => [
        surveyBanner,
      ];
}
