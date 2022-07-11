import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_improve_section.dart';

void main() {
  final linden = Linden();
  testWidgets(
    'GIVEN section THEN verify all widgets present',
    (final WidgetTester tester) async {
      await tester.pumpLindenApp(
        SettingsHelpImproveSection(
          onReportBugPressed: () {},
          onGiveFeedbackPressed: () {},
        ),
        initialLinden: linden,
      );

      expect(
        find.text(R.strings.settingsSectionTitleHelpImprove),
        findsOneWidget,
      );
      expect(find.text(R.strings.settingsHaveFoundBug), findsOneWidget);

      expect(find.byType(SettingsSection), findsOneWidget);
      expect(find.byType(SettingsCard), findsNWidgets(2));
      expect(find.byType(SettingsGroup), findsNWidgets(2));
      expect(find.byType(SettingsTile), findsNWidgets(2));
      expect(find.byType(Text), findsNWidgets(3));
    },
  );
  testWidgets(
    'GIVEN section WHEN clicked btn THEN proper callbacks are called',
    (final WidgetTester tester) async {
      var clickedReportBug = false;
      var clickedGiveFeedback = false;
      await tester.pumpLindenApp(
        SettingsHelpImproveSection(
          onReportBugPressed: () => clickedReportBug = true,
          onGiveFeedbackPressed: () => clickedGiveFeedback = true,
        ),
        initialLinden: linden,
      );

      final btnBugFinder = find.byKey(Keys.settingsHaveFoundBug);
      await tester.tap(btnBugFinder);
      expect(clickedReportBug, isTrue);

      final btnFeedbackFinder = find.byKey(Keys.settingsGiveFeedback);
      await tester.tap(btnFeedbackFinder);
      expect(clickedGiveFeedback, isTrue);
    },
  );
}
