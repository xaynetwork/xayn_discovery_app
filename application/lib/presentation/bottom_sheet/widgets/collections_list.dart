import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collection_list_item.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CollectionsListBottomSheet extends StatefulWidget {
  final List<Collection> collections;
  final OnSelectCollection onSelectCollection;
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

class _CollectionsListBottomSheetState extends State<CollectionsListBottomSheet>
    with CollectionCardManagersMixin {
  Collection? selectedCollection;
  List<Collection> collections = [];

  @override
  void initState() {
    selectedCollection = widget.initialSelectedCollection;
    collections = widget.collections;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: collections.length,
        itemExtent: R.dimen.collectionItemBottomSheetHeight,
        itemBuilder: (_, index) => _buildCollectionItem(collections[index]),
      );

  Widget _buildCollectionItem(Collection collection) =>
      BlocBuilder<CollectionCardManager, CollectionCardState>(
        bloc: managerOf(collection.id),
        builder: (context, cardState) => CollectionListItem(
          key: Keys.collectionItem(collection.id.value),
          collection: collection,
          collectionImage: cardState.image,
          isSelected: collection == selectedCollection,
          onSelectCollection: _onSelectCollection,
        ),
      );

  void _onSelectCollection(Collection? selected) {
    widget.onSelectCollection(selected);
    setState(() => selectedCollection = selected);
  }
}
