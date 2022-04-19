import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

/// Allows to cache [CardManagers] when viewing documents.
/// Note: [CardManagersMixin] will be disposed with the State of the widget thus in order to
/// prevent reloading on rotation or brightness changes it is recommended to use a [GlobalKey].
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
          imageManager: di.get()..getImage(document.resource.image),
          discoveryCardManager: di.get()..updateDocument(document),
        ),
      );

  /// Finds a CardManagersMixin in the buildContext and in the route hierarchy. Thus a [CardManagersMixin] can be declared
  /// within the Route hierarchy:
  ///
  /// i.e. Page1 -> Page2 (State extends CardManagersMixin) -> Page3 ->  Page4 (calls getManagers - and finds Page2.State)
  static CardManagers getManagers(BuildContext context, Document document) {
    final managersMixin =
        NavigatorVisitor.findStateOfType<CardManagersMixin>(context);
    if (managersMixin == null) {
      throw "Invalid Configuration: Calling State requires that a CardManagersMixin is present in the Widget Tree or the route hierarchy"
          ", did you forgot to use the mixin in the calling State?";
    }
    final cardManagers = managersMixin.managersOf(document);
    return cardManagers;
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
