import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/widget/add_topic_screen.dart';

class TopicChip extends StatelessWidget {
  factory TopicChip({
    required Topic topic,
    required OnTopicPressed onPressed,
    required bool isSelected,
    bool showIcon = false,
  }) =>
      isSelected
          ? TopicChip.selected(
              topic: topic,
              onPressed: onPressed,
              showIcon: showIcon,
            )
          : TopicChip.suggested(
              topic: topic,
              onPressed: onPressed,
              showIcon: showIcon,
            );

  TopicChip.selected({
    Key? key,
    required this.topic,
    required this.onPressed,
    this.showIcon = false,
  })  : iconAsset = R.assets.icons.cross,
        padding = EdgeInsets.symmetric(
          horizontal: R.dimen.unit1_25,
          vertical: R.dimen.unit0_75,
        ),
        backgroundColor = R.colors.addedTopicsBackgroundColor,
        border = Border.all(
          width: R.dimen.unit0_25,
          color: R.colors.addedTopicsBorderColor,
        ),
        super(key: key);

  TopicChip.suggested({
    Key? key,
    required this.topic,
    required this.onPressed,
    this.showIcon = false,
  })  : iconAsset = R.assets.icons.plus,
        padding = EdgeInsets.symmetric(
          horizontal: R.dimen.unit1_5,
          vertical: R.dimen.unit,
        ),
        backgroundColor = R.colors.suggestedTopicsBackgroundColor,
        border = null,
        super(key: key);

  final Topic topic;
  final OnTopicPressed onPressed;
  final bool showIcon;
  final String iconAsset;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final topicText = Text(
      topic.name,
      style: R.styles.topicChipTextStyle,
      maxLines: 2,
    );

    final icon = SvgPicture.asset(
      iconAsset,
      height: R.dimen.unit2,
      width: R.dimen.unit2,
    );

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
      borderRadius: decoration.borderRadius,
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
