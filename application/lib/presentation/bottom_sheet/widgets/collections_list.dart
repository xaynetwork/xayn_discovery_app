import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnSelectCollection = void Function(Collection?);

class CollectionsListBottomSheet extends StatefulWidget {
  final List<Collection> collections;
  final _OnSelectCollection onSelectCollection;
  final Collection? initialSelectedCollection;

  const CollectionsListBottomSheet({
    Key? key,
    required this.collections,
    required this.onSelectCollection,
    this.initialSelectedCollection,
  })  : assert(collections.length > 0,
            'collections must have at least one collection in CollectionsListBottomSheet'),
        super(key: key);

  @override
  _CollectionsListBottomSheetState createState() =>
      _CollectionsListBottomSheetState();
}

class _CollectionsListBottomSheetState
    extends State<CollectionsListBottomSheet> {
  Collection? selectedCollection;
  List<Collection> collections = [];

  @override
  void initState() {
    selectedCollection = widget.initialSelectedCollection;
    collections = _getOrderedCollections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _getCollectionItems(),
    );
  }

  List<Widget> _getCollectionItems() => collections
      .map<Widget>(
        (Collection it) => _CollectionItem(
          key: Keys.collectionItem(it.id.value),
          collection: it,
          isSelected: it == selectedCollection,
          onSelectCollection: _onSelectCollection,
        ),
      )
      .toList();

  void _onSelectCollection(Collection? selected) {
    widget.onSelectCollection(selected);
    setState(() => selectedCollection = selected);
  }

  List<Collection> _getOrderedCollections() {
    final list = List.of(widget.collections);
    final defaultCollection = list.firstWhere((it) => it.isDefault);
    list.remove(defaultCollection);
    list.sort((a, b) => a.name.compareTo(b.name));
    return [defaultCollection, ...list];
  }
}

class _CollectionItem extends StatelessWidget {
  final Collection collection;
  final bool isSelected;
  final _OnSelectCollection onSelectCollection;

  const _CollectionItem({
    Key? key,
    required this.collection,
    required this.isSelected,
    required this.onSelectCollection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final check = SvgPicture.asset(
      R.assets.icons.check,
      fit: BoxFit.fitHeight,
      color: R.colors.icon,
    );

    final visibleCheck = SizedBox(
      height: double.maxFinite,
      child: Visibility(
        visible: isSelected,
        child: check,
      ),
    );

    //todo: replace with asset
    final thumbnail = Container(
      height: 24,
      width: 24,
      color: const Color(0x816ADDCC),
    );

    final roundedThumbnail = ClipRRect(
      child: thumbnail,
      borderRadius: R.styles.roundBorder0_5,
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        roundedThumbnail,
        SizedBox(width: R.dimen.unit2),
        Text(collection.name, style: R.styles.bottomSheetText),
        const Spacer(flex: 9),
        Flexible(flex: 1, child: visibleCheck),
      ],
    );

    final item = SizedBox(
      child: row,
      height: R.dimen.unit5,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onSelectCollection(isSelected ? null : collection),
      child: item,
    );
  }
}
