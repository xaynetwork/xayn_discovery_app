import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';

typedef OnSelectCollection = void Function(UniqueId?);

class CollectionListItem extends StatelessWidget {
  final Collection collection;
  final Uint8List? collectionImage;
  final bool isSelected;
  final OnSelectCollection onSelectCollection;

  const CollectionListItem({
    Key? key,
    required this.collection,
    required this.isSelected,
    required this.onSelectCollection,
    this.collectionImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final check = SvgPicture.asset(
      R.assets.icons.check,
      fit: BoxFit.fitHeight,
      color: R.colors.icon,
      height: R.dimen.collectionItemBottomSheetHeight,
    );

    final thumbnail = collectionImage != null
        ? Thumbnail.memoryImage(collectionImage!)
        : Thumbnail.assetImage(
            R.assets.graphics.formsEmptyCollection,
            backgroundColor: R.colors.collectionsScreenCard,
          );

    final collectionName = Text(
      collection.name,
      style: R.styles.mBoldStyle,
      overflow: TextOverflow.ellipsis,
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        thumbnail,
        SizedBox(width: R.dimen.unit2),
        Expanded(child: collectionName),
        Visibility(visible: isSelected, child: check),
        SizedBox(width: R.dimen.unit2),
      ],
    );

    return InkWell(
      onTap: () => onSelectCollection(isSelected ? null : collection.id),
      child: row,
    );
  }
}
