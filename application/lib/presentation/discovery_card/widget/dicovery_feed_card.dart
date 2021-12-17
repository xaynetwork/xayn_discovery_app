import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_footer.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';

typedef ManagersCallback = void Function(DiscoveryCardManager, ImageManager);

class DiscoveryFeedCard extends DiscoveryCardBase {
  final ManagersCallback? onManagers;

  const DiscoveryFeedCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
    this.onManagers,
  }) : super(
          key: key,
          isPrimary: isPrimary,
          document: document,
          discoveryCardManager: discoveryCardManager,
          imageManager: imageManager,
        );

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedCardState();
}

class _DiscoveryFeedCardState
    extends DiscoveryCardBaseState<DiscoveryFeedCard> {
  @override
  void initState() {
    super.initState();

    widget.onManagers?.call(discoveryCardManager, imageManager);
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    final footer = DiscoveryCardFooter(
      title: webResource.title,
      url: webResource.url,
      provider: webResource.provider,
      datePublished: webResource.datePublished,
      onLikePressed: () => actionsManager.likeDocument(widget.document),
      onDislikePressed: () => actionsManager.dislikeDocument(widget.document),
    );

    return Stack(
      children: [
        Container(
            foregroundDecoration: BoxDecoration(
              gradient: buildGradient(),
            ),
            child: image),
        footer
      ],
    );
  }
}
