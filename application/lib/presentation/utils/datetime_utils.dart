import 'package:xayn_discovery_app/presentation/constants/r.dart';

// TODO: This is for testing purposes only. Will eventually be replaced by Andrii's logic.
DateTime subscriptionEndDate = DateTime.now().add(const Duration(days: 6));

extension DateTimeExtension on DateTime {
  int calculateDifferenceInDays(DateTime date) => DateTime(year, month, day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;

  bool get isToday => calculateDifferenceInDays(DateTime.now()) == 0;

  bool get isTomorrow => calculateDifferenceInDays(DateTime.now()) == 1;

  String get trialEndDateString {
    final now = DateTime.now();
    if (isBefore(now) || isAtSameMomentAs(now)) {
      return R.strings.trialBannerExpired;
    }

    if (isToday) {
      return R.strings.trialBannerEndsToday;
    }

    if (isTomorrow) {
      return R.strings.trialBannerEndsTomorrow;
    }

    final days = calculateDifferenceInDays(now);
    return R.strings.trialBannerEndsIn.replaceFirst('%s', days.toString());
  }
}
