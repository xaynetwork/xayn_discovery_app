import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/add_topic_screen.dart';

class TopicChip extends StatelessWidget {
  const TopicChip.selected({
    Key? key,
    required this.topic,
    required this.onPressed,
    this.showIcon = false,
  })  : isSelected = true,
        super(key: key);

  const TopicChip.suggested({
    Key? key,
    required this.topic,
    required this.onPressed,
    this.showIcon = false,
  })  : isSelected = false,
        super(key: key);

  final Topic topic;
  final OnTopicPressed onPressed;
  final bool showIcon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final topicText = Text(
      topic.name,
      style: R.styles.mStyle,
      maxLines: 2,
    );
    final icon = SvgPicture.asset(
      isSelected ? R.assets.icons.cross : R.assets.icons.plus,
      height: R.dimen.unit2,
      width: R.dimen.unit2,
    );
    final padding = EdgeInsets.symmetric(
      horizontal: R.dimen.unit1_5,
      vertical: R.dimen.unit,
    );
    final backgroundColor = isSelected
        ? R.colors.addedTopicsBackgroundColor
        : R.colors.suggestedTopicsBackgroundColor;
    final border = isSelected
        ? Border.all(
            width: R.dimen.unit0_25,
            color: R.colors.addedTopicsBorderColor,
          )
        : null;
    final decoration = BoxDecoration(
      border: border,
      borderRadius: BorderRadius.circular(R.dimen.unit),
      color: backgroundColor,
    );
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: topicText),
        if (showIcon) ...[
          SizedBox(width: R.dimen.unit1_25),
          icon,
        ],
      ],
    );

    final chip = Material(
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: () => onPressed(topic),
          child: Padding(
            padding: padding,
            child: row,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit0_75),
      child: chip,
    );
  }
}
