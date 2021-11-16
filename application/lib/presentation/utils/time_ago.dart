import 'package:intl/intl.dart';

//TODO: Use POEditor strings
String timeAgo(DateTime dateTime, DateFormat dateFormat) {
  final moment = DateTime.now();
  final elapsed = moment.difference(dateTime);
  final minutesAgo = elapsed.inMinutes;
  final hoursAgo = elapsed.inHours;
  final daysAgo = elapsed.inDays;

  if (minutesAgo < 5) {
    return 'moments ago';
  } else if (minutesAgo < 60) {
    final indicator = minutesAgo > 1 ? 'min ago' : 'min ago';
    return '$minutesAgo $indicator';
  } else if (hoursAgo < 24) {
    final indicator = hoursAgo > 1 ? 'hours ago' : 'hour ago';
    return '$hoursAgo $indicator';
  } else if (daysAgo < 31) {
    final indicator = daysAgo > 1 ? 'days ago' : 'day ago';
    return '$daysAgo $indicator';
  }

  return dateFormat.format(dateTime);
}
