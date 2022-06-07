import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
class SurveyBanner extends Equatable {
  final int numberOfTimesShown;
  final bool hasSurveyBannerBeenClicked;
  final int lastSessionNumberWhenShown;

  const SurveyBanner({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
    required this.lastSessionNumberWhenShown,
  });

  const SurveyBanner.initial()
      : numberOfTimesShown = 0,
        hasSurveyBannerBeenClicked = false,
        lastSessionNumberWhenShown = 0;

  SurveyBanner copyWith({
    int? numberOfTimesShown,
    bool? hasSurveyBannerBeenClicked,
    int? lastSessionNumberWhenShown,
  }) =>
      SurveyBanner(
        numberOfTimesShown: numberOfTimesShown ?? this.numberOfTimesShown,
        hasSurveyBannerBeenClicked:
            hasSurveyBannerBeenClicked ?? this.hasSurveyBannerBeenClicked,
        lastSessionNumberWhenShown:
            lastSessionNumberWhenShown ?? this.lastSessionNumberWhenShown,
      );

  SurveyBanner clicked({required int sessionNumber}) => SurveyBanner(
        numberOfTimesShown: numberOfTimesShown,
        hasSurveyBannerBeenClicked: true,
        lastSessionNumberWhenShown: sessionNumber,
      );

  @override
  List<Object?> get props => [
        numberOfTimesShown,
        hasSurveyBannerBeenClicked,
        lastSessionNumberWhenShown,
      ];
}
