import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_imptrove_section.dart';

void main() {
  final linden = Linden(newColors: true);
  testWidgets(
    'GIVEN section THEN verify all widgets present',
    (final WidgetTester tester) async {
      await tester.pumpLindenApp(
        SettingsHelpImproveSection(
          onFindBugPressed: () {},
        ),
        initialLinden: linden,
      );

      expect(
        find.text(R.strings.settingsSectionTitleHelpImprove),
        findsOneWidget,
      );
      expect(find.text(R.strings.settingsHaveFoundBug), findsOneWidget);

      expect(find.byType(SettingsSection), findsOneWidget);
      expect(find.byType(SettingsCard), findsOneWidget);
      expect(find.byType(SettingsGroup), findsOneWidget);
      expect(find.byType(SettingsTile), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2));
    },
  );
  testWidgets(
    'GIVEN section WHEN clicked btn THEN proper callbacks are called',
    (final WidgetTester tester) async {
      var clicked = false;
      await tester.pumpLindenApp(
        SettingsHelpImproveSection(
          onFindBugPressed: () => clicked = true,
        ),
        initialLinden: linden,
      );

      final btnFinder = find.byKey(Keys.settingsHaveFoundBug);
      await tester.tap(btnFinder);
      expect(clicked, isTrue);
    },
  );
}
