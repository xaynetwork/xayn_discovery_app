import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/real_time.dart';

extension DateTimeExtension on DateTime {
  int calculateDifferenceInDays(DateTime date) => DateTime(year, month, day)
      .difference(DateTime(date.year, date.month, date.day))
      .inDays;

  bool get isToday => calculateDifferenceInDays(_realTime.now) == 0;

  bool get isTomorrow => calculateDifferenceInDays(_realTime.now) == 1;

  RealTime get _realTime => di.get();

  String get trialEndDateString {
    final now = _realTime.now;
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
    return R.strings.trialBannerEndsIn.format(days.toString());
  }

  String get shortDateFormat => DateFormat('dd.MM.yyyy').format(this);
}
