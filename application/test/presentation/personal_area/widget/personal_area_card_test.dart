import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/personal_area/widget/personal_area_card.dart';

import '../../utils/extensions.dart';

void main() {
  const title = 'CardTitle';
  const color = Colors.red;
  const iconPath = 'packages/xayn_design/assets/icons/arrow_left.svg';
  const bgPath = 'packages/xayn_design/assets/graphics/forms_green.svg';
  const key = Key('PersonalAreaCardKey');
  Widget build([VoidCallback? onPressed]) => PersonalAreaCard(
        title: title,
        color: color,
        svgIconPath: iconPath,
        svgBackground: bgPath,
        onPressed: onPressed ?? () {},
        key: key,
      );
  final linden = Linden(newColors: true);

  testWidgets(
    'GIVEN widget WHEN  THEN verify all nested widgets is correct',
    (final WidgetTester tester) async {
      await tester.pumpLindenApp(Center(child: build()), initialLinden: linden);

      final height = tester.getSize(find.byType(PersonalAreaCard));
      expect(height.height, equals(150));

      expect(find.byType(AppGhostButton), findsOneWidget);
      expect(find.byType(SvgPicture), findsNWidgets(2));
      expect(find.text(title), findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN widget WHEN click on the key THEN callback is triggered',
    (final WidgetTester tester) async {
      var callbackClicked = false;
      void callback() {
        callbackClicked = true;
      }

      await tester.pumpLindenApp(build(callback), initialLinden: linden);

      expect(callbackClicked, isFalse);
      await tester.tap(key.finds());
      expect(callbackClicked, isTrue);
    },
  );
}
