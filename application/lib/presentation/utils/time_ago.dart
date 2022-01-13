import 'package:intl/intl.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

String timeAgo(DateTime dateTime, DateFormat dateFormat) {
  final moment = DateTime.now();
  final elapsed = moment.difference(dateTime);
  final minutesAgo = elapsed.inMinutes;
  final hoursAgo = elapsed.inHours;
  final daysAgo = elapsed.inDays;

  if (minutesAgo < 5) {
    return R.strings.momentsAgo;
  } else if (minutesAgo < 60) {
    return '$minutesAgo ${R.strings.minAgo}';
  } else if (hoursAgo < 24) {
    final indicator = hoursAgo > 1 ? R.strings.hoursAgo : R.strings.hourAgo;
    return '$hoursAgo $indicator';
  } else if (daysAgo < 31) {
    final indicator = daysAgo > 1 ? R.strings.daysAgo : R.strings.dayAgo;
    return '$daysAgo $indicator';
  }

  return dateFormat.format(dateTime);
}
