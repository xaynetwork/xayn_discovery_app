import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:quiver/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';

@lazySingleton
class CollectionCardManagersCache {
  late final Map<UniqueId, CollectionCardManager> _collectionCardManagers =
      LruMap(maximumSize: 20);

  void dispose() {
    _collectionCardManagers
      ..forEach((_, manager) => manager.close())
      ..clear();
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
