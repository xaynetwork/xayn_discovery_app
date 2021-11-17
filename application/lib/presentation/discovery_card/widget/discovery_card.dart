import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';

/// A widget which displays a discovery card.
class DiscoveryCard extends StatefulWidget {
  const DiscoveryCard({
    Key? key,
    required this.snippet,
    required this.imageUrl,
    required this.url,
    required this.footer,
  }) : super(key: key);

  final Widget footer;

  /// The snippet of the card, displayed on the primary page
  final String snippet;

  /// The url of the card's background image
  final String imageUrl;

  /// The url of the card's news article
  final Uri url;

  @override
  State<StatefulWidget> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard> {
  late final DiscoveryCardManager _discoveryCardManager;

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

    _discoveryCardManager.updateUri(widget.url);
    _discoveryCardManager.updateImageUri(Uri.parse(widget.imageUrl));
  }

  @override
  void didUpdateWidget(DiscoveryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _discoveryCardManager.updateUri(widget.url);
    }

    if (oldWidget.imageUrl != widget.imageUrl) {
      _discoveryCardManager.updateImageUri(Uri.parse(widget.imageUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
        bloc: _discoveryCardManager,
        builder: (context, state) {
          final snippets = state.paragraphs
              .map((it) => Bidi.stripHtmlIfNeeded(it))
              .toList(growable: false);

          return LayoutBuilder(builder: (context, constraints) {
            return _buildCardDisplayStack(
              imageUrl: widget.imageUrl,
              snippets: snippets,
              palette: state.paletteGenerator,
              constraints: constraints,
            );
          });
        });
  }

  Widget _buildCardDisplayStack({
    required String imageUrl,
    required List<String> snippets,
    required BoxConstraints constraints,
    PaletteGenerator? palette,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: R.colors.swipeCardBackground),
        ),
        CardBackground(
          imageUrl: imageUrl,
          constraints: constraints,
          palette: palette,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DiscoveryCardBody(
                snippets: [widget.snippet, ...snippets],
                palette: palette,
              ),
            ),
            widget.footer,
          ],
        ),
      ],
    );
  }
}

class CardBackground extends StatelessWidget {
  const CardBackground({
    Key? key,
    required this.imageUrl,
    required this.constraints,
    this.palette,
  }) : super(key: key);
  final String imageUrl;
  final BoxConstraints constraints;
  final PaletteGenerator? palette;

  @override
  Widget build(BuildContext context) {
    final backgroundPane = ColoredBox(
      color: palette?.dominantColor?.color ?? R.colors.swipeCardBackground,
    );

    final isImageNotAvailable = !imageUrl.startsWith('http');

    final backgroundImage = isImageNotAvailable
        ? backgroundPane
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder:
                (context, Widget child, ImageChunkEvent? loadingProgress) {
              return loadingProgress != null ? backgroundPane : child;
            },
            errorBuilder: (context, e, s) =>
                Text('Unable to load image with url: $imageUrl\n\n$e'),
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
