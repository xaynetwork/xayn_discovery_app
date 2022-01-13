import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/share_app_section.dart';

void main() {
  final linden = Linden(newColors: true);
  testWidgets(
    'GIVEN section THEN verify all widgets present',
    (final WidgetTester tester) async {
      await tester.pumpLindenApp(
        ShareAppSection(
          onShareAppPressed: () {},
        ),
        initialLinden: linden,
      );

      expect(
        find.text(R.strings.settingsSectionTitleSpreadTheWord),
        findsOneWidget,
      );
      expect(find.text(R.strings.settingsShareBtn), findsOneWidget);

      expect(find.byType(SettingsSection), findsOneWidget);
      expect(find.byType(SettingsCard), findsNothing);
      expect(find.byType(SettingsGroup), findsNothing);
      expect(find.byType(SettingsTile), findsNothing);
      expect(find.byType(AppRaisedButton), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2));
    },
  );

  testWidgets(
    'GIVEN section WHEN clicked btn THEN proper callbacks are called',
    (final WidgetTester tester) async {
      var clicked = false;
      await tester.pumpLindenApp(
        ShareAppSection(
          onShareAppPressed: () => clicked = true,
        ),
        initialLinden: linden,
      );

      final btnFinder = find.byKey(Keys.settingsShareBtn);
      await tester.tap(btnFinder);
      expect(clicked, isTrue);
    },
  );
}
