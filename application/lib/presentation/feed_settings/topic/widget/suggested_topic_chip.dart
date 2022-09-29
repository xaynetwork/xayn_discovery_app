import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/add_topic_screen.dart';

class SuggestedTopicChip extends StatelessWidget {
  const SuggestedTopicChip({
    Key? key,
    required this.topic,
    required this.onPressed,
  }) : super(key: key);

  final String topic;
  final OnTopicPressed onPressed;

  @override
  Widget build(BuildContext context) {
    final topicText = Text(
      topic,
      style: R.styles.topicChipTextStyle,
    );
    final icon = SvgPicture.asset(
      R.assets.icons.plus,
      height: R.dimen.unit2,
      width: R.dimen.unit2,
    );
    final padding = EdgeInsets.symmetric(
      horizontal: R.dimen.unit1_5,
      vertical: R.dimen.unit,
    );
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(R.dimen.unit),
      color: R.colors.suggestedTopicsBackgroundColor,
    );

    final chip = InkWell(
      onTap: () => onPressed(topic),
      child: Container(
        decoration: decoration,
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            topicText,
            SizedBox(width: R.dimen.unit1_25),
            icon,
          ],
        ),
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit0_75),
      child: chip,
    );
  }
}
