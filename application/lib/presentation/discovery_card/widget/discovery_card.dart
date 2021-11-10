import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';

/// A widget which displays a discovery card.
class DiscoveryCard extends StatefulWidget {
  const DiscoveryCard({
    Key? key,
    required this.title,
    required this.snippet,
    required this.imageUrl,
    required this.url,
  }) : super(key: key);

  /// The title of the card, displayed on the primary page
  final String title;

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
              ),
            );
          });
        });
  }

  Widget _buildCardDisplayStack({
    required String imageUrl,
    required List<String> paragraphs,
    PaletteGenerator? palette,
  }) {
    final backgroundImage = Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, e, s) => Container(),
    );
    final primaryStoryPage = DiscoveryCardPrimaryBody(
      palette: palette,
      title: widget.title,
      snippet: widget.snippet,
    );
    final secondaryStoryPages = paragraphs.map(
      (it) => DiscoveryCardSecondaryBody(
        palette: palette,
        html: it,
        onLink: (url) async {
          _discoveryCardManager.updateUri(Uri.parse(url));

          return true;
        },
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Stack(
        children: [
          Positioned.fill(child: backgroundImage),
          PageView(
            controller: _pageController,
            children: [
              primaryStoryPage,
              ...secondaryStoryPages,
            ],
          ),
        ],
      ),
    );
  }
}
