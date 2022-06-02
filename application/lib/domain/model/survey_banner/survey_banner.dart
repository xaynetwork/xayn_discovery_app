import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class SurveyBanner extends Equatable {
  final int numberOfTimesShown;
  final bool hasSurveyBannerBeenClicked;

  const SurveyBanner({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
  });

  const SurveyBanner.initial()
      : numberOfTimesShown = 0,
        hasSurveyBannerBeenClicked = false;

  SurveyBanner copyWith({
    int? numberOfTimesShown,
    bool? hasSurveyBannerBeenClicked,
  }) =>
      SurveyBanner(
        numberOfTimesShown: numberOfTimesShown ?? this.numberOfTimesShown,
        hasSurveyBannerBeenClicked:
            hasSurveyBannerBeenClicked ?? this.hasSurveyBannerBeenClicked,
      );

  SurveyBanner clicked() => SurveyBanner(
        numberOfTimesShown: numberOfTimesShown,
        hasSurveyBannerBeenClicked: true,
      );

  @override
  List<Object?> get props => [
        numberOfTimesShown,
        hasSurveyBannerBeenClicked,
      ];
}
