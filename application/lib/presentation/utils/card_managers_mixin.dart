import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin CardManagersMixin<T extends StatefulWidget> on State<T> {
  late final Map<DocumentId, CardManagers> _cardManagers = {};

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
      _cardManagers.remove(key.documentId)?.closeAll();
    }
  }

  @mustCallSuper
  CardManagers managersOf(Document document) => _cardManagers.putIfAbsent(
        document.documentId,
        () => CardManagers(
          imageManager: di.get()..getImage(document.resource.thumbnail),
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

  /// Instead of using the mixin you can also register a factory of CardManagers
  /// that also
  /// Returns a function to dispose those managers
  static VoidCallback registerCardManagerCacheInDi(String scopeName) {
    di.pushNewScope(scopeName: scopeName);
    final cache = <DocumentId, CardManagers>{};
    CardManagers createCardManagers(Document document) {
      final imageManager = di.get<ImageManager>();
      final discoveryCardManager = di.get<DiscoveryCardManager>();
      final uri = document.resource.thumbnail;
      imageManager.getImage(uri);
      discoveryCardManager.updateDocument(document);
      return CardManagers(
          imageManager: imageManager,
          discoveryCardManager: discoveryCardManager);
    }

    di.registerFactoryParam<CardManagers, Document, void>(
        (Document? document, _) => cache.putIfAbsent(
            document!.documentId, () => createCardManagers(document)));

    return () {
      cache.forEach((key, value) {
        value.closeAll();
      });
      cache.clear();
      di.popScopesTill(scopeName);
    };
  }
}
