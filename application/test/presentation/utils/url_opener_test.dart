import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/presentation/utils/url_opener.dart';

void main() {
  late final UrlOpener urlOpener;

  setUp(() {
    urlOpener = UrlOpener();
  });

  test(
    'GIVEN NON url string  WHEN openUrl method called THEN throw AssertError',
    () {
      const fakeUrls = [
        'xayn.com',
        'hello',
      ];
      for (final fakeUrl in fakeUrls) {
        expect(
          () => urlOpener.openUrl(fakeUrl),
          throwsA(isA<AssertionError>()),
        );
      }
    },
  );
}
