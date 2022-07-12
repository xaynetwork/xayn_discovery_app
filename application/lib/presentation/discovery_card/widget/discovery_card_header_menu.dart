import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import '../../feed_settings/page/source/manager/sources_state.dart';

enum DiscoveryCardHeaderMenuItemEnum {
  openInBrowser,
  excludeSource,
  includeSource,
}

class DiscoveryCardHeaderMenu extends StatelessWidget {
  DiscoveryCardHeaderMenu({
    Key? key,
    required this.itemsMap,
    required this.source,
    this.onClose,
  }) : super(key: key);

  final VoidCallback? onClose;
  final Map<DiscoveryCardHeaderMenuItemEnum, DiscoveryCardHeaderMenuItem>
      itemsMap;
  final Source source;

  late final SourcesManager _sourcesManager = di.get()..init();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return AppMenu.single(
      top: topPadding + R.dimen.cardNotchSize + R.dimen.unit,
      start: R.dimen.unit4,
      width: R.dimen.screenWidth - R.dimen.unit8,
      borderRadius: R.styles.roundBorder3,
      onDragOutside: onClose,
      onPop: onClose,
      onTapOutside: onClose,
      child: _buildMenuBody(itemsMap),
    );
  }

  Widget _buildMenuBody(
          Map<DiscoveryCardHeaderMenuItemEnum, DiscoveryCardHeaderMenuItem>
              items) =>
      BlocBuilder<SourcesManager, SourcesState>(
        bloc: _sourcesManager,
        builder: (context, state) {
          final itemsList = _buildItemsList(state);
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(
                vertical: R.dimen.unit3, horizontal: R.dimen.unit3),
            itemBuilder: (_, i) {
              final menuItem = itemsList.elementAt(i);
              if (i == itemsList.length - 1) {
                return _buildRow(menuItem);
              }
              return _buildRowWithBottomPadding(
                _buildRow(menuItem),
              );
            },
            itemCount: itemsList.length,
          );
        },
      );

  List<DiscoveryCardHeaderMenuItem> _buildItemsList(SourcesState state) {
    final itemsList = [
      itemsMap[DiscoveryCardHeaderMenuItemEnum.openInBrowser]!
    ];
    if (state.excludedSources.contains(source)) {
      itemsList.add(itemsMap[DiscoveryCardHeaderMenuItemEnum.includeSource]!);
    } else {
      itemsList.add(itemsMap[DiscoveryCardHeaderMenuItemEnum.excludeSource]!);
    }
    return itemsList;
  }

  Widget _buildRow(DiscoveryCardHeaderMenuItem item) => InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.all(R.dimen.unit),
          child: Row(
            children: [
              SvgPicture.asset(
                item.iconPath,
                width: R.dimen.iconSize,
                color: R.colors.icon,
              ),
              SizedBox(
                width: R.dimen.unit2,
              ),
              Flexible(child: Text(item.title, maxLines: 2)),
            ],
          ),
        ),
      );

  Widget _buildRowWithBottomPadding(Widget child) => Padding(
        padding: EdgeInsets.only(
          bottom: R.dimen.unit,
        ),
        child: child,
      );
}

class DiscoveryCardHeaderMenuItem {
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  DiscoveryCardHeaderMenuItem({
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  DiscoveryCardHeaderMenuItem copyWith({
    String? iconPath,
    String? title,
    VoidCallback? onTap,
  }) =>
      DiscoveryCardHeaderMenuItem(
        iconPath: iconPath ?? this.iconPath,
        title: title ?? this.title,
        onTap: onTap ?? this.onTap,
      );
}

class DiscoveryCardHeaderMenuHelper {
  static DiscoveryCardHeaderMenuItem buildOpenInBrowserItem(
          {required VoidCallback onTap}) =>
      DiscoveryCardHeaderMenuItem(
        iconPath: R.assets.icons.globe,
        title: R.strings.readerModeUnableToLoadCTA,
        onTap: onTap,
      );

  static DiscoveryCardHeaderMenuItem buildExcludeSourceItem(
          {required VoidCallback onTap}) =>
      DiscoveryCardHeaderMenuItem(
        iconPath: R.assets.icons.block,
        title: R.strings.excludeSourceMenuItemTitle,
        onTap: onTap,
      );

  static DiscoveryCardHeaderMenuItem buildIncludeSourceBackItem(
          {required VoidCallback onTap}) =>
      DiscoveryCardHeaderMenuItem(
        iconPath: R.assets.icons.plus,
        title: R.strings.allowSourceBackMenuItemTitle,
        onTap: onTap,
      );
}
