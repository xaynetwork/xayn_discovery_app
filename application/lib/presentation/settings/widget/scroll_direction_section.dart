import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_scroll_direction.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

typedef OnScrollDirectionSelected = Function(
    DiscoveryFeedScrollDirection scrollDirection);

class ScrollDirectionSection extends StatelessWidget {
  final DiscoveryFeedScrollDirection scrollDirection;
  final OnScrollDirectionSelected onSelected;

  const ScrollDirectionSection({
    Key? key,
    required this.scrollDirection,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection.custom(
        title: Strings.settingsSectionScrollDirection,
        topPadding: R.dimen.unit,
        child: SettingsSelectable.icons(
            items: DiscoveryFeedScrollDirection.values.map(_getItem).toList()),
      );

  SettingsSelectableData _getItem(
          DiscoveryFeedScrollDirection scrollDirection) =>
      SettingsSelectableData(
        key: _getKey(scrollDirection),
        title: _getTitle(scrollDirection),
        svgIconPath: _getIcon(scrollDirection),
        isSelected: scrollDirection == this.scrollDirection,
        onPressed: () => onSelected(scrollDirection),
      );

  Key _getKey(DiscoveryFeedScrollDirection scrollDirection) {
    switch (scrollDirection) {
      case DiscoveryFeedScrollDirection.vertical:
        return Keys.settingsScrollDirectionVertical;
      case DiscoveryFeedScrollDirection.horizontal:
        return Keys.settingsScrollDirectionHorizontal;
    }
  }

  String _getTitle(DiscoveryFeedScrollDirection scrollDirection) {
    switch (scrollDirection) {
      case DiscoveryFeedScrollDirection.vertical:
        return Strings.settingsScrollDirectionVertical;
      case DiscoveryFeedScrollDirection.horizontal:
        return Strings.settingsScrollDirectionHorizontal;
    }
  }

  String _getIcon(DiscoveryFeedScrollDirection scrollDirection) {
    switch (scrollDirection) {
      case DiscoveryFeedScrollDirection.vertical:
        return R.assets.icons.arrowDown;
      case DiscoveryFeedScrollDirection.horizontal:
        return R.assets.icons.arrowRight;
    }
  }
}
