import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class DiscoveryCardHeaderMenu extends StatelessWidget {
  const DiscoveryCardHeaderMenu({
    Key? key,
    required this.items,
    this.onClose,
  }) : super(key: key);

  final VoidCallback? onClose;
  final List<DiscoveryCardHeaderMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return AppMenu.single(
      top: R.dimen.unit15,
      start: R.dimen.unit4,
      width: R.dimen.screenWidth - R.dimen.unit8,
      borderRadius: R.styles.roundBorder3,
      onTapOutside: onClose,
      onDragOutside: onClose,
      onPop: onClose,
      child: _buildMenuBody(items),
    );
  }

  Widget _buildMenuBody(List<DiscoveryCardHeaderMenuItem> items) =>
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(
            vertical: R.dimen.unit3, horizontal: R.dimen.unit3),
        itemBuilder: (_, i) {
          final menuItem = items.elementAt(i);
          if (i == items.length - 1) {
            return _buildRow(menuItem);
          }
          return _buildRowWithBottomPadding(
            _buildRow(menuItem),
          );
        },
        itemCount: items.length,
      );

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
