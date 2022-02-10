import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/datetime_utils.dart';

void main() {
  group('DateTime Utils: ', () {
    test('GIVEN date in the past THEN trial end date string is expired', () {
      final date = DateTime.now().subtract(const Duration(days: 1));
      expect(date.trialEndDateString, equals(R.strings.trialBannerExpired));
    });

    test('GIVEN current date THEN trial end date string is expired', () {
      final date = DateTime.now();
      expect(date.trialEndDateString, equals(R.strings.trialBannerExpired));
    });

    test('GIVEN date is today THEN trial end date string ends today', () {
      final date = DateTime.now().add(const Duration(minutes: 1));
      expect(date.trialEndDateString, equals(R.strings.trialBannerEndsToday));
    });

    test('GIVEN date is tomorrow THEN trial end date string ends tomorrow', () {
      final date = DateTime.now().add(const Duration(days: 1));
      expect(
          date.trialEndDateString, equals(R.strings.trialBannerEndsTomorrow));
    });

    test(
        'GIVEN date is 5 days in the future THEN trial end date string ends in 5 days',
        () {
      final date = DateTime.now().add(const Duration(days: 5));
      final expectedString =
          R.strings.trialBannerEndsIn.replaceFirst('%s', '5');
      expect(date.trialEndDateString, equals(expectedString));
    });
  });
}
