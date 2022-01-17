import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnSelectCollection = void Function(Collection?);

class CollectionsListBottomSheet extends StatefulWidget {
  final List<Collection> collections;
  final _OnSelectCollection onSelectCollection;
  final int initialIndex;

  const CollectionsListBottomSheet({
    Key? key,
    required this.collections,
    required this.onSelectCollection,
    this.initialIndex = 0,
  })  : assert(collections.length > 0,
            'collections must have at least one collection in CollectionsListBottomSheet'),
        assert(initialIndex < collections.length,
            'initial index must not exceed collections length in CollectionsListBottomSheet'),
        assert(initialIndex >= 0,
            'initial index must not be negative in CollectionsListBottomSheet'),
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
    selectedCollection = _getSelectedCollection();
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
          //todo: add to keys
          key: Key('collectionItem' + it.id.value),
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

  Collection? _getSelectedCollection() =>
      widget.initialIndex < 0 ? null : widget.collections[widget.initialIndex];

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
    final item = Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(collection.name),
          if (isSelected)
            SvgPicture.asset(
              R.assets.icons.check,
              fit: BoxFit.none,
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => onSelectCollection(isSelected ? null : collection),
      child: item,
    );
  }
}
