import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_readability/xayn_readability.dart' hide ReaderMode;

import 'discovery_card_footer.dart';

const Duration kAnimationDuration = Duration(milliseconds: 600);

/// A widget which displays a discovery card.
class DiscoveryCard extends StatefulWidget {
  final bool isPrimary;

  const DiscoveryCard({
    Key? key,
    required this.isPrimary,
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

    final readerMode = Visibility(
      visible: _shouldShowReaderMode,
      maintainState: true,
      child: Padding(
        padding: EdgeInsets.all(R.dimen.unit),
        child: AnimatedOpacity(
          opacity: _shouldShowReaderMode ? 1.0 : .0,
          duration: kAnimationDuration * 2,
          child: ReaderMode(
            title: title,
            snippet: snippet,
            imageUri: Uri.parse(imageUrl),
            processHtmlResult: processHtmlResult,
          ),
        ),
      ),
    );
    final footer = DiscoveryCardFooter(
      title: widget.webResource.title,
      url: widget.webResource.url,
      provider: widget.webResource.provider,
      datePublished: widget.webResource.datePublished,
      onFooterPressed: () => setState(
          () => setState(() => _shouldShowReaderMode = !_shouldShowReaderMode)),
    );
    final bodyAndFooter = Column(
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

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          AnimatedContainer(
            height: _shouldShowReaderMode ? constraints.maxHeight : .0,
            duration: kAnimationDuration,
            child: ColoredBox(color: R.colors.swipeCardBackground),
          ),
          Positioned.fill(
            top: constraints.maxHeight / 4,
            child: Container(
              color: R.colors.swipeCardBackground,
              child: readerMode,
            ),
          ),
          InkWell(
            onTap: () =>
                setState(() => _shouldShowReaderMode = !_shouldShowReaderMode),
            child: _CardBackground(
              imageUrl: imageUrl,
              constraints: constraints,
              dominantColor: palette?.dominantColor?.color,
              isDocked: _shouldShowReaderMode,
            ),
          ),
          AnimatedContainer(
            height: _shouldShowReaderMode ? .0 : constraints.maxHeight,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            duration: kAnimationDuration,
            child: OverflowBox(
              maxHeight: constraints.maxHeight,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                opacity: _shouldShowReaderMode ? .0 : 1.0,
                duration: kAnimationDuration,
                child: bodyAndFooter,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CardBackground extends StatelessWidget {
  const _CardBackground({
    Key? key,
    required this.imageUrl,
    required this.constraints,
    required this.isDocked,
    this.dominantColor,
  }) : super(key: key);
  final String imageUrl;
  final BoxConstraints constraints;
  final Color? dominantColor;
  final bool isDocked;

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

    final shadedBackgroundImage = AnimatedContainer(
      duration: kAnimationDuration,
      width: constraints.maxWidth,
      height:
          isDocked ? constraints.maxHeight / 4 : 2 * constraints.maxHeight / 3,
      decoration: const BoxDecoration(),
      clipBehavior: Clip.antiAlias,
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

    return isImageNotAvailable ? backgroundPane : shadedBackgroundImage;
  }
}
