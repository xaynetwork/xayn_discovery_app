import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';

import 'discovery_card_footer.dart';

/// A widget which displays a discovery card.
class DiscoveryCard extends StatefulWidget {
  const DiscoveryCard({
    Key? key,
    required this.webResource,
  }) : super(key: key);

  final WebResource webResource;

  @override
  State<StatefulWidget> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard> {
  late final DiscoveryCardManager _discoveryCardManager;

  Uri get url => widget.webResource.url;
  String get imageUrl => widget.webResource.displayUrl.toString();
  String get snippet => widget.webResource.snippet;

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

    _discoveryCardManager.updateUri(url);
    _discoveryCardManager.updateImageUri(Uri.parse(imageUrl));
  }

  @override
  void didUpdateWidget(DiscoveryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.webResource.url;
    final oldImageUrl = oldWidget.webResource.displayUrl.toString();

    if (oldUrl != url) {
      _discoveryCardManager.updateUri(url);
    }

    if (oldImageUrl != imageUrl) {
      _discoveryCardManager.updateImageUri(Uri.parse(imageUrl));
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
          bloc: _discoveryCardManager,
          builder: (context, state) {
            final snippets = state.paragraphs
                .map((it) => Bidi.stripHtmlIfNeeded(it))
                .toList(growable: false);

            return LayoutBuilder(
              builder: (context, constraints) => _buildCardDisplayStack(
                imageUrl: imageUrl,
                snippets: snippets,
                palette: state.paletteGenerator,
                constraints: constraints,
              ),
            );
          });

  Widget _buildCardDisplayStack({
    required String imageUrl,
    required List<String> snippets,
    required BoxConstraints constraints,
    PaletteGenerator? palette,
  }) {
    final footer = DiscoveryCardFooter(
      title: widget.webResource.title,
      url: widget.webResource.url,
      provider: widget.webResource.provider,
      datePublished: widget.webResource.datePublished,
      onFooterPressed: () => debugPrint('Open article'),
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
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DiscoveryCardBody(
                snippets: [snippet, ...snippets],
                palette: palette,
              ),
            ),
            footer,
          ],
        ),
      ],
    );
  }
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
