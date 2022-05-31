import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class SurveyBannerData extends Equatable {
  final int numberOfTimesShown;
  final bool hasSurveyBannerBeenClicked;

  const SurveyBannerData({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
  });

  const SurveyBannerData.initial()
      : numberOfTimesShown = 0,
        hasSurveyBannerBeenClicked = false;

  SurveyBannerData copyWith({
    int? numberOfTimesShown,
    bool? hasSurveyBannerBeenClicked,
  }) =>
      SurveyBannerData(
        numberOfTimesShown: numberOfTimesShown ?? this.numberOfTimesShown,
        hasSurveyBannerBeenClicked:
            hasSurveyBannerBeenClicked ?? this.hasSurveyBannerBeenClicked,
      );

  @override
  List<Object?> get props => [
        numberOfTimesShown,
        hasSurveyBannerBeenClicked,
      ];
}
