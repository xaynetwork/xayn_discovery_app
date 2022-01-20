import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/widget/country_item.dart';

void main() {
  const iconPathCross = 'packages/xayn_design/assets/icons/cross.svg';
  const iconPathPlus = 'packages/xayn_design/assets/icons/plus.svg';
  const countryName = 'USA';
  const countryFlagPath =
      'packages/xayn_design/assets/illustrations/flag_usa.svg';

  const countryCode = 'USA';
  const countryLangCode = 'en';
  const countryLanguage = 'English';
  Country createCountry({String? language, Key? key}) => Country(
        name: countryName,
        svgFlagAssetPath: countryFlagPath,
        countryCode: countryCode,
        langCode: countryLangCode,
        language: language,
        key: key,
      );

  testWidgets(
    'GIVEN country without language and isSelected=false WHEN creating widget THEN verify all items set correctly',
    (final WidgetTester tester) async {
      final country = createCountry(language: null);
      await tester.pumpLindenApp(CountryItem(
          country: country, isSelected: false, onActionPressed: () {}));

      expect(find.text(countryName), findsOneWidget);
      expect(find.text(countryLanguage), findsNothing);
      expect(find.byType(AppGhostButton), findsOneWidget);
      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsNWidgets(2));

      final flagWidget =
          (svgFinder.first.evaluate().first.widget as SvgPicture);
      expect(
        (flagWidget.pictureProvider as ExactAssetPicture).assetName,
        countryFlagPath,
      );

      final actionWidget =
          (svgFinder.last.evaluate().first.widget as SvgPicture);
      expect(
        (actionWidget.pictureProvider as ExactAssetPicture).assetName,
        iconPathPlus,
      );
    },
  );

  testWidgets(
    'GIVEN country with language and isSelected=true WHEN creating widget THEN verify all items set correctly',
    (final WidgetTester tester) async {
      final country = createCountry(language: countryLanguage);
      await tester.pumpLindenApp(CountryItem(
          country: country, isSelected: true, onActionPressed: () {}));

      expect(find.text(countryName), findsOneWidget);
      expect(find.text(countryLanguage), findsOneWidget);
      expect(find.byType(AppGhostButton), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsNWidgets(2));

      final flagWidget =
          (svgFinder.first.evaluate().first.widget as SvgPicture);
      expect(
        (flagWidget.pictureProvider as ExactAssetPicture).assetName,
        countryFlagPath,
      );

      final actionWidget =
          (svgFinder.last.evaluate().first.widget as SvgPicture);
      expect(
        (actionWidget.pictureProvider as ExactAssetPicture).assetName,
        iconPathCross,
      );
    },
  );
  testWidgets(
    'GIVEN country with the key WHEN key is pressed THEN verify callback was called',
    (final WidgetTester tester) async {
      const key = Key('key');
      final country = createCountry(key: key);
      var actionWasPressed = false;
      await tester.pumpLindenApp(CountryItem(
        country: country,
        isSelected: true,
        onActionPressed: () => actionWasPressed = !actionWasPressed,
      ));

      expect(actionWasPressed, isFalse);
      await tester.tap(find.byKey(key));
      expect(actionWasPressed, isTrue);
    },
  );
}
