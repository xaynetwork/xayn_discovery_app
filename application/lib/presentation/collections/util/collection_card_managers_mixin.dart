import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';

/// Mixin used for handling the retrieval and the disposal of the collection
/// card manager per each provided collectionId
mixin CollectionCardManagersMixin<T extends StatefulWidget> on State<T> {
  late final Map<UniqueId, CollectionCardManager> _collectionCardManagers = {};

  @override
  void dispose() {
    _collectionCardManagers
      ..forEach((_, manager) => manager.close())
      ..clear();
    super.dispose();
  }

  /// Generate a collection card manager and call the
  /// method for retrieving the data to display
  @mustCallSuper
  CollectionCardManager managerOf(UniqueId collectionId) =>
      _collectionCardManagers.putIfAbsent(
        collectionId,
        () => di.get()..retrieveCollectionCardInfo(collectionId),
      );
}
