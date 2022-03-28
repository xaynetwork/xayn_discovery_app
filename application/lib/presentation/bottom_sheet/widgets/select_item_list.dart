import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef OnSelectItem<T> = void Function(T);
typedef ItemBuilder<T> = Widget Function(
    BuildContext context, T item, bool selected);

class SelectItemList<T> extends StatelessWidget {
  final List<T> items;
  final OnSelectItem<T> onSelectItem;
  final Set<T> preSelectedItems;
  final ItemBuilder<T> builder;
  final GetTitle<T> getTitle;
  final GetImage<T> getImage;

  SelectItemList({
    Key? key,
    required this.items,
    required this.onSelectItem,
    Set<T>? preSelectedItems,
    ItemBuilder<T>? builder,
    required this.getTitle,
    required this.getImage,
  })  : assert(items.isNotEmpty, 'Items must have at least one item.'),
        preSelectedItems = preSelectedItems ?? {},
        builder = builder ??
            createDefaultBuilder<T>(getTitle, getImage, onSelectItem),
        super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemExtent: R.dimen.collectionItemBottomSheetHeight,
        itemBuilder: (_, index) {
          final item = items[index];
          return builder(context, item, preSelectedItems.contains(item));
        },
      );

  static ItemBuilder<T> createDefaultBuilder<T>(GetTitle<T> getTitle,
      GetImage<T> getImage, OnSelectItem<T> onSelectItem) {
    return (BuildContext context, T item, bool isSelected) => _ListItem(
        item: item,
        isSelected: isSelected,
        onSelectItem: onSelectItem,
        getTitle: getTitle,
        getImage: getImage);
  }
}

typedef GetTitle<T> = String Function(T);
typedef GetImage<T> = Widget Function(T);

class _ListItem<T> extends StatelessWidget {
  final T item;
  final bool isSelected;
  final OnSelectItem<T> onSelectItem;
  final GetTitle<T> getTitle;
  final GetImage<T> getImage;

  const _ListItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onSelectItem,
    required this.getTitle,
    required this.getImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final check = SvgPicture.asset(
      R.assets.icons.check,
      fit: BoxFit.fitHeight,
      color: R.colors.icon,
      height: R.dimen.collectionItemBottomSheetHeight,
    );

    final image = getImage(item);

    final collectionName = Text(
      getTitle(item),
      style: R.styles.mBoldStyle,
      overflow: TextOverflow.ellipsis,
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        image,
        SizedBox(width: R.dimen.unit2),
        Expanded(child: collectionName),
        Visibility(visible: isSelected, child: check),
        SizedBox(width: R.dimen.unit2),
      ],
    );

    return InkWell(
      onTap: () => onSelectItem(item),
      child: row,
    );
  }
}
