import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/widget/country_item.dart';

import '../../test_utils/extensions.dart';

part 'country_feed_settings_page_test.utils.dart';

void main() {
  group('Constructor asserts', () {
    testWidgets(
      'GIVEN empty selectedCountries list WHEN build widget THEN throw AssertionError',
      (final WidgetTester tester) async {
        expect(
          () => buildPage(selectedCountries: []),
          throwsA(isA<AssertionError>()),
        );
      },
    );
    testWidgets(
      'GIVEN empty unSelectedCountries list WHEN build widget THEN DO NOT throw AssertionError',
      (final WidgetTester tester) async {
        expect(
          buildPage(unSelectedCountries: []),
          isA<Widget>(),
        );
      },
    );
    testWidgets(
      'GIVEN same country in SelectedCountries and  unSelectedCountries lists WHEN build widget THEN throw AssertionError',
      (final WidgetTester tester) async {
        expect(
          () => buildPage(
            selectedCountries: [countryUSA],
            unSelectedCountries: [countryUSA, countryGermany],
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  testWidgets(
    'GIVEN default setup WHEN build page widget THEN verify correct children',
    (final WidgetTester tester) async {
      await tester.pumpLindenApp(buildPage());

      final hintText = R.strings.feedSettingsScreenContryListHint
          .replaceFirst('%s', maxSelectedCountryAmount.toString());
      expect(find.text(hintText), findsOneWidget);
      expect(find.text(R.strings.feedSettingsScreenActiveCountryListSubtitle),
          findsOneWidget);
      expect(find.text(R.strings.feedSettingsScreenInActiveCountryListSubtitle),
          findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CountryItem), findsNWidgets(3));
    },
  );

  group('Click actions', () {
    testWidgets(
      'GIVEN  WHEN click on the selected country key THEN call onRemoveCountryPressed with that country',
      (final WidgetTester tester) async {
        late Country country;
        await tester.pumpLindenApp(buildPage(onRemoveCountryPressed: (_) {
          country = _;
        }));

        await tester.tap(keyUSA.finds());

        expect(country, equals(countryUSA));
      },
    );
    testWidgets(
      'GIVEN  WHEN click on the unSelected country key THEN call onAddCountryPressed with that country',
      (final WidgetTester tester) async {
        late Country country;
        await tester.pumpLindenApp(buildPage(onAddCountryPressed: (_) {
          country = _;
        }));

        await tester.tap(keyDE.finds());

        expect(country, equals(countryGermany));
      },
    );
  });
}
