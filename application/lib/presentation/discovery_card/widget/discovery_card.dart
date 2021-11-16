import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();

    _discoveryCardManager = di.get();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();

    _discoveryCardManager.close();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _pageIndex = 0;
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
          final imageCollection = [widget.imageUrl, ...state.images];
          final imageIndex = imageCollection.length ~/
              (state.paragraphs.length + 1) *
              _pageIndex;
          final imageUrl = imageCollection[imageIndex];

          return LayoutBuilder(builder: (context, constraints) {
            return GestureDetector(
              onTapUp: (details) {
                setState(() {
                  if (details.localPosition.dx <= constraints.maxWidth / 2) {
                    if (_pageIndex > 0) _pageIndex--;
                  } else {
                    if (_pageIndex < state.paragraphs.length) _pageIndex++;
                  }
                });

                _pageController.animateToPage(
                  _pageIndex,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              child: _buildCardDisplayStack(
                imageUrl: imageUrl,
                paragraphs: state.paragraphs,
                palette: state.paletteGenerator,
                constraints: constraints,
              ),
            );
          });
        });
  }

  Widget _buildCardDisplayStack({
    required String imageUrl,
    required List<String> paragraphs,
    required BoxConstraints constraints,
    PaletteGenerator? palette,
  }) {
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
              R.colors.swipeCardBackground.withAlpha(120),
              Colors.transparent,
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

    final storyPages = [widget.snippet, ...paragraphs].map(
      (it) => DiscoveryCardBody(
        palette: palette,
        snippet: it,
        footer: widget.footer,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(
              color: R.colors.swipeCardBackground,
            ),
          ),
          isImageNotAvailable ? backgroundPane : shadedBackgroundImage,
          PageView(
            controller: _pageController,
            children: storyPages.toList(),
          ),
        ],
      ),
    );
  }
}
