import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/uri_helper.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin CardManagersMixin<T extends StatefulWidget> on State<T> {
  late final Map<Document, CardManagers> _cardManagers = {};

  @override
  void dispose() {
    _cardManagers
      ..forEach((_, managers) => managers.closeAll())
      ..clear();

    super.dispose();
  }

  @mustCallSuper
  void removeObsoleteCardManagers(Iterable<Document> results) {
    for (var key in results) {
      _cardManagers.remove(key)?.closeAll();
    }
  }

  @mustCallSuper
  Future<CardManagers> managersOf(Document document) async {
    if (!_cardManagers.containsKey(document)) {
      _cardManagers[document] = CardManagers(
        imageManager: di.get()
          ..getImage(UriHelper.safeUri(document.webResource.displayUrl)),
        discoveryCardManager: await di.getAsync()
          ..updateDocument(document),
      );
    }

    return _cardManagers[document]!;
  }
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
