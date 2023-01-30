import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';

@lazySingleton
class CardManagersCache {
  late final Map<Uri, CardManagers> _cardManagers = {};

  void dispose() {
    _cardManagers
      ..forEach((_, managers) => managers.closeAll())
      ..clear();
  }

  @mustCallSuper
  void removeObsoleteCardManagers(Iterable<Document> results) {
    for (var key in results) {
      _cardManagers.remove(key.resource.url)?.closeAll();
    }
  }

  @mustCallSuper
  CardManagers managersOf(Document document) => _cardManagers.putIfAbsent(
        document.resource.url,
        () => CardManagers(
          imageManager: di.get()..getImage(document.resource.image),
          discoveryCardManager: di.get()..updateDocument(document),
        ),
      );
}

@immutable
class CardManagers {
  final DiscoveryCardManager discoveryCardManager;
  final ImageManager imageManager;

  const CardManagers({
    required this.imageManager,
    required this.discoveryCardManager,
  });

  void closeAll() {
    imageManager.close();
    discoveryCardManager.close();
  }
}
