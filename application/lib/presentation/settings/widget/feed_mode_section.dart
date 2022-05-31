import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_mode.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef OnFeedModeSelected = Function(FeedMode mode);

class SettingsFeedModeSection extends StatelessWidget {
  final FeedMode mode;
  final OnFeedModeSelected onSelected;

  const SettingsFeedModeSection({
    Key? key,
    required this.mode,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection.custom(
        title: R.strings.settingsSectionTitleAppTheme,
        child: SettingsSelectable.icons(
          items: FeedMode.values.map(_getItem).toList(),
        ),
      );

  SettingsSelectableData _getItem(FeedMode mode) => SettingsSelectableData(
        key: _getKey(mode),
        title: _getTitle(mode),
        svgIconPath: _getIcon(mode),
        isSelected: mode == this.mode,
        onPressed: () => onSelected(mode),
      );

  Key _getKey(FeedMode mode) {
    switch (mode) {
      case FeedMode.stream:
        return const Key("stream");
      case FeedMode.carousel:
        return const Key("carousel");
    }
  }

  String _getTitle(FeedMode mode) {
    return mode.description;
  }

  String _getIcon(FeedMode mode) {
    switch (mode) {
      case FeedMode.stream:
        return R.assets.icons.list;
      case FeedMode.carousel:
        return R.assets.icons.carousel;
    }
  }
}
