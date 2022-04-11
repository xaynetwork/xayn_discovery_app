import 'package:flutter/cupertino.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/card_managers_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class DiFactories {
  const DiFactories._();

  /// Instead of using the mixin you can also register a factory of CardManagers
  /// that also
  /// Returns a function to dispose those managers
  static VoidCallback registerCardManagerCacheInDi(String scopeName) {
    di.pushNewScope(scopeName: scopeName);
    final cache = <DocumentId, CardManagers>{};
    CardManagers createCardManagers(Document document) {
      final imageManager = di.get<ImageManager>();
      final discoveryCardManager = di.get<DiscoveryCardManager>();
      final uri = document.resource.image;
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
