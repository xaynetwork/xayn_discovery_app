import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/topic/topic.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class TopicListItem extends StatelessWidget {
  final Topic topic;
  final VoidCallback onRemoveTapped;

  const TopicListItem({
    Key? key,
    required this.topic,
    required this.onRemoveTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildName()),
        _buildActionIcon(),
      ],
    );
    final decoration = BoxDecoration(
        color: R.colors.settingsCardBackground,
        borderRadius: R.styles.roundBorder,
        border: Border.all(
          width: R.dimen.unit0_25 / 2,
          color: R.colors.transparent,
        ));
    final container = Material(
      child: Ink(
        height: R.dimen.iconButtonSize,
        decoration: decoration,
        child: InkWell(
          onTap: onRemoveTapped,
          radius: R.dimen.unit,
          child: Padding(
            padding: EdgeInsets.only(left: R.dimen.unit1_5),
            child: row,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: R.dimen.unit),
      child: container,
    );
  }

  Widget _buildName() => Text(
        topic.name,
        style: R.styles.mBoldStyle,
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildActionIcon() {
    final icon = R.assets.icons.cross;
    final btn = SvgPicture.asset(
      icon,
      color: R.colors.icon,
    );
    return SizedBox(
      width: R.dimen.iconButtonSize,
      child: Padding(
        padding: EdgeInsets.all(R.dimen.unit2),
        child: btn,
      ),
    );
  }
}
