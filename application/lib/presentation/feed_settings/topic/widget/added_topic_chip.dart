import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/add_topic_screen.dart';

class AddedTopicChip extends StatelessWidget {
  const AddedTopicChip({
    Key? key,
    required this.topic,
    required this.onPressed,
  }) : super(key: key);

  final Topic topic;
  final OnTopicPressed onPressed;

  @override
  Widget build(BuildContext context) {
    final topicText = Text(
      topic.name,
      style: R.styles.mStyle,
    );
    final icon = SvgPicture.asset(
      R.assets.icons.cross,
      height: R.dimen.unit2,
      width: R.dimen.unit2,
    );
    final padding = EdgeInsets.symmetric(
      horizontal: R.dimen.unit1_5,
      vertical: R.dimen.unit,
    );
    final decoration = BoxDecoration(
      border: Border.all(
        width: R.dimen.unit0_25,
        color: R.colors.addedTopicsBorderColor,
      ),
      borderRadius: BorderRadius.circular(R.dimen.unit),
      color: R.colors.addedTopicsBackgroundColor,
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
