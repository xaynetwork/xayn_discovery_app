import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_readability/xayn_readability.dart' hide ReaderMode;

import 'discovery_card_footer.dart';

/// A widget which displays a discovery card.
class DiscoveryCard extends AutomaticKeepAlive {
  final bool isPrimary;

  const DiscoveryCard({
    Key? key,
    required this.isPrimary,
    required this.webResource,
  }) : super(key: key);

  final WebResource webResource;

  @override
  State<AutomaticKeepAlive> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard>
    with AutomaticKeepAliveClientMixin {
  late final DiscoveryCardManager _discoveryCardManager;

  Uri get url => widget.webResource.url;
  String get imageUrl => widget.webResource.displayUrl.toString();
  String get snippet => widget.webResource.snippet;
  String get title => widget.webResource.title;

  bool _shouldShowReaderMode = false;

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
    final oldUrl = oldWidget.webResource.url;
    final oldImageUrl = oldWidget.webResource.displayUrl.toString();

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
              processHtmlResult: state.result,
            ),
          );
        });
  }

  Widget _buildCardDisplayStack({
    required String imageUrl,
    required List<String> snippets,
    required BoxConstraints constraints,
    required bool isPrimary,
    ProcessHtmlResult? processHtmlResult,
    PaletteGenerator? palette,
  }) {
    final allSnippets = isPrimary ? [snippet, ...snippets] : [snippet];

    final footer = DiscoveryCardFooter(
        title: widget.webResource.title,
        url: widget.webResource.url,
        shouldDisplayReaderMode: _shouldShowReaderMode,
        readerModeBuilder: () => processHtmlResult != null
            ? ReaderMode(
                title: title,
                snippet: snippet,
                imageUri: Uri.parse(imageUrl),
                processHtmlResult: processHtmlResult)
            : const CircularProgressIndicator(),
        provider: widget.webResource.provider,
        datePublished: widget.webResource.datePublished,
        onFooterPressed: () => debugPrint('Open article'),
        onTitlePressed: () => setState(() =>
            setState(() => _shouldShowReaderMode = !_shouldShowReaderMode)));

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: R.colors.swipeCardBackground),
          ),
          AnimatedPositioned(
            child: _CardBackground(
              imageUrl: imageUrl,
              constraints: constraints,
              dominantColor: palette?.dominantColor?.color,
            ),
            duration: const Duration(milliseconds: 400),
            left: 0,
            right: 0,
            top: 0,
            bottom: _shouldShowReaderMode ? constraints.maxHeight - 260.0 : .0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_shouldShowReaderMode)
                Expanded(
                  child: DiscoveryCardBody(
                    snippets: allSnippets,
                    palette: palette,
                  ),
                ),
              _shouldShowReaderMode ? Expanded(child: footer) : footer,
            ],
          ),
        ],
      );
    });
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
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder:
                (context, Widget child, ImageChunkEvent? loadingProgress) =>
                    loadingProgress != null ? backgroundPane : child,
            errorBuilder: (context, e, s) =>
                Text('Unable to load image with url: $imageUrl\n\n$e'),
          );

    final shadedBackgroundImage =
        LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 2 * constraints.maxHeight / 3,
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
      );
    });

    return isImageNotAvailable ? backgroundPane : shadedBackgroundImage;
  }
}
