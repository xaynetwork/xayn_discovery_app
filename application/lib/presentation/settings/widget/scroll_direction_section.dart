import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

typedef OnScrollDirectionSelected = Function(DiscoveryFeedAxis axis);

class SettingsScrollDirectionSection extends StatelessWidget {
  final DiscoveryFeedAxis axis;
  final OnScrollDirectionSelected onSelected;

  const SettingsScrollDirectionSection({
    Key? key,
    required this.axis,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection.custom(
        title: Strings.settingsSectionScrollDirection,
        child: SettingsSelectable.icons(
            items: DiscoveryFeedAxis.values.map(_getItem).toList()),
      );

  SettingsSelectableData _getItem(DiscoveryFeedAxis axis) =>
      SettingsSelectableData(
        key: _getKey(axis),
        title: _getTitle(axis),
        svgIconPath: _getIcon(axis),
        isSelected: axis == this.axis,
        onPressed: () => onSelected(axis),
      );

  Key _getKey(DiscoveryFeedAxis scrollDirection) {
    switch (scrollDirection) {
      case DiscoveryFeedAxis.vertical:
        return Keys.settingsScrollDirectionVertical;
      case DiscoveryFeedAxis.horizontal:
        return Keys.settingsScrollDirectionHorizontal;
    }
  }

  String _getTitle(DiscoveryFeedAxis scrollDirection) {
    switch (scrollDirection) {
      case DiscoveryFeedAxis.vertical:
        return Strings.settingsScrollDirectionVertical;
      case DiscoveryFeedAxis.horizontal:
        return Strings.settingsScrollDirectionHorizontal;
    }
  }

  String _getIcon(DiscoveryFeedAxis scrollDirection) {
    switch (scrollDirection) {
      case DiscoveryFeedAxis.vertical:
        return R.assets.icons.arrowDown;
      case DiscoveryFeedAxis.horizontal:
        return R.assets.icons.arrowRight;
    }
  }
}
