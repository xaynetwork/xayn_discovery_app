import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';

typedef TapCallback = void Function(Document);
typedef CardManagerCallback = void Function(DiscoveryCardManager);
typedef ImageManagerCallback = void Function(ImageManager);

class DiscoveryFeedCard extends DiscoveryCardBase {
  final TapCallback? onTap;
  final CardManagerCallback? onCardManager;
  final ImageManagerCallback? onImageManager;

  const DiscoveryFeedCard({
    Key? key,
    required bool isPrimary,
    required Document document,
    DiscoveryCardManager? discoveryCardManager,
    ImageManager? imageManager,
    this.onTap,
    this.onCardManager,
    this.onImageManager,
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

    widget.onCardManager?.call(discoveryCardManager);
    widget.onImageManager?.call(imageManager);
  }

  @override
  Widget buildFromState(
      BuildContext context, DiscoveryCardState state, Widget image) {
    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            R.colors.swipeCardBackground.withAlpha(120),
            R.colors.swipeCardBackground.withAlpha(40),
            R.colors.swipeCardBackground.withAlpha(40),
            R.colors.swipeCardBackground.withAlpha(120),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.15, 0.8, 1],
        ),
      ),
      child: GestureDetector(
        onTap: () => widget.onTap?.call(widget.document),
        child: image,
      ),
    );
  }
}
