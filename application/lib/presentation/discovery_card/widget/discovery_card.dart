import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';

import 'discovery_card_footer.dart';

/// A widget which displays a discovery card.
class DiscoveryCard extends AutomaticKeepAlive {
  final bool isPrimary;
  final Document document;

  const DiscoveryCard({
    Key? key,
    required this.isPrimary,
    required this.document,
  }) : super(key: key);

  @override
  State<AutomaticKeepAlive> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard>
    with AutomaticKeepAliveClientMixin {
  late final DiscoveryCardManager _discoveryCardManager;

  WebResource get webResource => widget.document.webResource;
  Uri get url => webResource.url;
  String get imageUrl => webResource.displayUrl.toString();
  String get snippet => webResource.snippet;

  @override
  void initState() {
    super.initState();

    _discoveryCardManager = di.get();
  }

  @override
  void dispose() {
    super.dispose();

    _discoveryCardManager.close();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.isPrimary) {
      _discoveryCardManager.updateUri(url);
    }

    _discoveryCardManager.updateImageUri(Uri.parse(imageUrl));
  }

  @override
  void didUpdateWidget(DiscoveryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.document.webResource.url;
    final oldImageUrl = oldWidget.document.webResource.displayUrl.toString();

    if (widget.isPrimary && oldUrl != url) {
      _discoveryCardManager.updateUri(url);
    }

    if (oldImageUrl != imageUrl) {
      _discoveryCardManager.updateImageUri(Uri.parse(imageUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
        bloc: _discoveryCardManager,
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) => _buildCardDisplayStack(
              isPrimary: widget.isPrimary,
              imageUrl: imageUrl,
              snippets: state.paragraphs,
              palette: state.paletteGenerator,
              constraints: constraints,
            ),
          );
        });
  }

  Widget _buildCardDisplayStack({
    required String imageUrl,
    required List<String> snippets,
    required BoxConstraints constraints,
    required bool isPrimary,
    PaletteGenerator? palette,
  }) {
    final DiscoveryCardActionsManager _actionsManager = di.get();

    final allSnippets = isPrimary ? [snippet, ...snippets] : [snippet];

    final footer = DiscoveryCardFooter(
      title: webResource.title,
      url: webResource.url,
      provider: webResource.provider,
      datePublished: webResource.datePublished,
      onFooterPressed: () => debugPrint('Open article'),
      onLikePressed: () => _actionsManager.likeDocument(widget.document),
      onDislikePressed: () => _actionsManager.dislikeDocument(widget.document),
    );

    final cardWithFooter = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DiscoveryCardBody(
            snippets: allSnippets,
            palette: palette,
          ),
        ),
        footer,
      ],
    );
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: R.colors.swipeCardBackground),
        ),
        _CardBackground(
          imageUrl: imageUrl,
          constraints: constraints,
          dominantColor: palette?.dominantColor?.color,
        ),
        cardWithFooter,
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CardBackground extends StatelessWidget {
  const _CardBackground({
    Key? key,
    required this.imageUrl,
    required this.constraints,
    this.dominantColor,
  }) : super(key: key);
  final String imageUrl;
  final BoxConstraints constraints;
  final Color? dominantColor;

  @override
  Widget build(BuildContext context) {
    final backgroundPane = ColoredBox(
      color: dominantColor ?? R.colors.swipeCardBackground,
    );

    final isImageNotAvailable = !imageUrl.startsWith('http');

    final backgroundImage = isImageNotAvailable
        ? backgroundPane
        : CachedImage(
            uri: Uri.parse(imageUrl),
            fit: BoxFit.cover,
            loadingBuilder: (context, progress) => backgroundPane,
            errorBuilder: (context) =>
                Text('Unable to load image with url: $imageUrl'),
          );

    final shadedBackgroundImage = Positioned.fill(
      bottom: constraints.maxHeight / 3,
      child: Container(
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              R.colors.swipeCardBackground,
              R.colors.swipeCardBackground.withAlpha(40),
              R.colors.swipeCardBackground.withAlpha(120),
              R.colors.swipeCardBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.15, 0.8, 1],
          ),
        ),
        child: backgroundImage,
      ),
    );
    return isImageNotAvailable ? backgroundPane : shadedBackgroundImage;
  }
}
