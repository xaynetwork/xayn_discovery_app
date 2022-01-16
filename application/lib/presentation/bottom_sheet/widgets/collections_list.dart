import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnSelectCollection = void Function(Collection);

//should be ordered alphabetically except the read later
// selecting a  selected one, puts triggers null on collection -> remove from current collection.
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
        assert(initialIndex < collections.length - 1,
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
  late Collection selectedCollection;

  get collections => widget.collections;

  @override
  void initState() {
    selectedCollection = collections[widget.initialIndex];
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

  _onSelectCollection(Collection selected) {
    widget.onSelectCollection(selected);
    setState(() => selectedCollection = selected);
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
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
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
      onTap: () => onSelectCollection(collection),
      child: item,
    );
  }
}
