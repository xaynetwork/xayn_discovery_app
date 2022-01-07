import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';

void main() {
  const theme = AppTheme.system;
  final linden = Linden(newColors: true);
  testWidgets(
    'GIVEN section widget THEN title and selectableSettings are present',
    (final WidgetTester tester) async {
      final widget = SettingsAppThemeSection(
          theme: theme, onSelected: (AppTheme theme) {});
      await tester.pumpLindenApp(
        widget,
        withScaffold: true,
        initialLinden: linden,
      );

      expect(find.byType(SettingsSection), findsOneWidget);
      expect(find.byType(SettingsSelectable), findsOneWidget);
      expect(find.text(Strings.settingsSectionTitleAppTheme), findsOneWidget);
      expect(find.text(Strings.settingsAppThemeSystem), findsOneWidget);
      expect(find.text(Strings.settingsAppThemeLight), findsOneWidget);
      expect(find.text(Strings.settingsAppThemeDark), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(4));
    },
  );
  testWidgets(
    'GIVEN section widget WHEN click on item THEN callback return proper value',
    (final WidgetTester tester) async {
      var expectedTheme = theme;
      final widget = SettingsAppThemeSection(
        theme: theme,
        onSelected: (AppTheme theme) {
          expectedTheme = theme;
        },
      );
      await tester.pumpLindenApp(
        widget,
        withScaffold: true,
        initialLinden: linden,
      );
      final btnFinder = find.byKey(Keys.settingsThemeDark);
      await tester.tap(btnFinder);

      expect(expectedTheme, equals(AppTheme.dark));
    },
  );
}
