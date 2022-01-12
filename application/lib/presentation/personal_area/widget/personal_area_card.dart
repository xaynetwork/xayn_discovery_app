import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

const _itemHeight = 150.0;

class PersonalAreaCard extends StatelessWidget {
  final String title;
  final Color color;
  final String svgIconPath;
  final String svgBackground;
  final VoidCallback onPressed;

  const PersonalAreaCard({
    required this.title,
    required this.color,
    required this.svgIconPath,
    required this.svgBackground,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = SizedBox(
      child: _buildContent(),
      height: _itemHeight,
    );
    return AppGhostButton(
      contentPadding: EdgeInsets.zero,
      onPressed: onPressed,
      child: item,
      borderRadius: UnterDenLinden.getLinden(context).styles.roundBorder1_5,
      backgroundColor: color,
    );
  }

  Widget _buildContent() {
    final icon = SvgPicture.asset(
      svgIconPath,
      color: R.colors.iconInverse,
      width: R.dimen.iconSize,
      height: R.dimen.iconSize,
    );
    final title = Text(
      this.title,
      style: R.styles.appHeadlineText
          ?.copyWith(color: R.colors.primaryTextInverse),
    );
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(height: R.dimen.unit),
        title,
      ],
    );
    final background = SvgPicture.asset(svgBackground, height: _itemHeight);
    final columnPadding = R.dimen.unit3;
    return Stack(
      children: [
        Positioned.fill(left: null, child: background),
        Positioned(left: columnPadding, bottom: columnPadding, child: column),
      ],
    );
  }
}
