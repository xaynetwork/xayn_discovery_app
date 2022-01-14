import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/uri_helper.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin CardManagersMixin<T extends StatefulWidget> on State<T> {
  late final Map<Document, _CardManagers> _cardManagers = {};

  @override
  void dispose() {
    _cardManagers
      ..forEach((_, managers) => managers.closeAll())
      ..clear();
    super.dispose();
  }

  _CardManagers managersOf(Document document) => _cardManagers.putIfAbsent(
      document,
      () => _CardManagers(
            imageManager: di.get()
              ..getImage(UriHelper.safeUri(document.webResource.displayUrl)),
            discoveryCardManager: di.get()..updateUri(document.webResource.url),
          ));
}

@immutable
class _CardManagers {
  final DiscoveryCardManager discoveryCardManager;
  final ImageManager imageManager;

  const _CardManagers({
    required this.imageManager,
    required this.discoveryCardManager,
  });

  void closeAll() {
    imageManager.close();
    discoveryCardManager.close();
  }
}
