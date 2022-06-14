import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class SourceListItem extends StatelessWidget {
  final Source source;
  final bool isPendingRemoval;
  final bool isPendingAddition;
  final VoidCallback onActionTapped;

  const SourceListItem({
    Key? key,
    required this.source,
    required this.isPendingAddition,
    required this.isPendingRemoval,
    required this.onActionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFlag(),
        Expanded(child: _buildName()),
        _buildActionIcon(),
      ],
    );
    final decoration = BoxDecoration(
        color: isPendingRemoval
            ? R.colors.pageBackground
            : R.colors.settingsCardBackground,
        borderRadius: R.styles.roundBorder,
        border: Border.all(
          width: R.dimen.unit0_25 / 2,
          color:
              isPendingRemoval ? R.colors.iconDisabled : R.colors.transparent,
        ));
    final container = Material(
      child: Ink(
        height: R.dimen.iconButtonSize,
        decoration: decoration,
        child: InkWell(
          onTap: onActionTapped,
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

  Widget _buildName() {
    final title = Text(
      source.value,
      style: R.styles.mBoldStyle,
      overflow: TextOverflow.ellipsis,
    );
    final children = <Widget>[
      title,
    ];

    final subTitleText = isPendingRemoval
        ? 'This source was just removed from the list'
        : isPendingAddition
            ? 'This source will be added to the list'
            : null;
    if (subTitleText != null) {
      final subTitle = Text(
        subTitleText,
        style: R.styles.sStyle.copyWith(
          color: R.colors.primaryAction,
        ),
      );
      children.add(subTitle);
    }

    return Padding(
      padding: EdgeInsets.only(left: R.dimen.unit1_5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildActionIcon() {
    final icon = isPendingRemoval ? R.assets.icons.plus : R.assets.icons.cross;
    final btn = SvgPicture.asset(
      icon,
      color: R.colors.icon,
    );
    return SizedBox(
        width: R.dimen.iconButtonSize,
        child: Padding(
          padding: EdgeInsets.all(R.dimen.unit2),
          child: btn,
        ));
  }

  Widget _buildFlag() => ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: buildThumbnailFromFaviconHost(source.value));
}
