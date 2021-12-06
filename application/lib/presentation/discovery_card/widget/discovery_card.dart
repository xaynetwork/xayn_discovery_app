import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/images/widget/cached_image.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode.dart';
import 'package:xayn_discovery_app/presentation/widget/nav_bar_items.dart';
import 'package:xayn_readability/xayn_readability.dart' hide ReaderMode;

import 'discovery_card_footer.dart';

/// A widget which displays a discovery card.
class DiscoveryCard extends StatefulWidget {
  final bool isPrimary;
  final Duration? transitionDuration;
  final Document document;

  const DiscoveryCard({
    Key? key,
    required this.isPrimary,
    required this.document,
    this.transitionDuration,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard> with NavBarConfigMixin {
  late final DiscoveryCardManager _discoveryCardManager;
  late final Duration _transitionDuration;

  WebResource get webResource => widget.document.webResource;

  Uri get url => webResource.url;

  String get imageUrl => webResource.displayUrl.toString();

  String get snippet => webResource.snippet;

  String get title => webResource.title;

  DiscoveryCardState? _currentState;

  @override
  void didUpdateWidget(covariant DiscoveryCard oldWidget) {
    if (oldWidget.isPrimary != widget.isPrimary) {
      NavBarContainer.updateNavBar(context);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  NavBarConfig? get navBarConfig {
    final ignoreConfig = !widget.isPrimary ||
        _currentState == null ||
        _currentState?.isInReaderMode == false;


    return ignoreConfig
        ? null
        : NavBarConfig(
            [
              buildNavBarItemArrowLeft(
                onPressed: _discoveryCardManager.toggleReaderMode,
              ),
              buildNavBarItemLike(onPressed: () {}, isLiked: false),
              buildNavBarItemDisLike(onPressed: () {}, isDisLiked: false),
              buildNavBarItemShare(onPressed: () {})
            ],
            isWidthExpanded: true,
          );
  }

  @override
  void initState() {
    super.initState();

    _discoveryCardManager = di.get();
    _transitionDuration =
        widget.transitionDuration ?? R.animations.cardTransitionDuration;
  }

  @override
  void dispose() {
    super.dispose();

    _discoveryCardManager.close();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPrimary) {
      _discoveryCardManager.updateUri(url);
    }

    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
        bloc: _discoveryCardManager,
        builder: (context, state) {
          if (widget.isPrimary &&
              (_currentState == null ||
                  _currentState!.isInReaderMode != state.isInReaderMode)) {
            _currentState = state;
            NavBarContainer.updateNavBar(context);
          }

          return LayoutBuilder(
            builder: (context, constraints) => _buildCardDisplayStack(
              isPrimary: widget.isPrimary,
              isInReaderMode: state.isInReaderMode,
              imageUrl: imageUrl,
              snippets: state.paragraphs,
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
    required bool isInReaderMode,
    ProcessHtmlResult? processHtmlResult,
  }) {
    final DiscoveryCardActionsManager _actionsManager = di.get();

    final allSnippets = isPrimary ? [snippet, ...snippets] : [snippet];
    final fullSize = constraints.maxHeight;
    final imageAsHeaderSize = fullSize / 4;
    final expandedReaderModeSize = 3 * imageAsHeaderSize;

    final cardBackground = _CardBackground(
      imageUrl: imageUrl,
      constraints: constraints,
      isDocked: isInReaderMode,
      transitionDuration: _transitionDuration,
    );
    final readerMode = Visibility(
      visible: isInReaderMode,
      maintainState: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit3,
          vertical: R.dimen.unit2,
        ),
        child: AnimatedOpacity(
          opacity: isInReaderMode ? 1.0 : .0,
          duration: _transitionDuration * 2,
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
      title: webResource.title,
      url: webResource.url,
      provider: webResource.provider,
      datePublished: webResource.datePublished,
      onFooterPressed: _discoveryCardManager.toggleReaderMode,
      onLikePressed: () => _actionsManager.likeDocument(widget.document),
      onDislikePressed: () => _actionsManager.dislikeDocument(widget.document),
    );
    final bodyAndFooter = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DiscoveryCardBody(
            snippets: allSnippets,
          ),
        ),
        footer,
      ],
    );
    final children = [
      Positioned.fill(
        top: imageAsHeaderSize,
        child: _buildAnimatedGrowing(
          maxHeight: expandedReaderModeSize,
          height: isInReaderMode ? expandedReaderModeSize : .0,
          opacity: isInReaderMode ? 1.0 : .0,
          alignment: Alignment.bottomCenter,
          child: ColoredBox(
            color: R.colors.cardBackground,
            child: readerMode,
          ),
        ),
      ),
      InkWell(
        onTap: _discoveryCardManager.toggleReaderMode,
        child: cardBackground,
      ),
      _buildAnimatedGrowing(
        maxHeight: fullSize,
        height: isInReaderMode ? .0 : fullSize,
        opacity: isInReaderMode ? .0 : 1.0,
        alignment: Alignment.topCenter,
        child: bodyAndFooter,
      ),
    ];

    return Container(
      width: constraints.maxWidth,
      height: fullSize,
      color: R.colors.swipeCardBackground,
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _buildAnimatedGrowing({
    required Widget child,
    required Alignment alignment,
    required double opacity,
    required double maxHeight,
    required double height,
  }) =>
      AnimatedContainer(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(),
        duration: _transitionDuration,
        child: OverflowBox(
          maxHeight: maxHeight,
          alignment: alignment,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: _transitionDuration,
            child: child,
          ),
        ),
      );
}

class _CardBackground extends StatelessWidget {
  const _CardBackground({
    Key? key,
    required this.imageUrl,
    required this.constraints,
    required this.isDocked,
    required this.transitionDuration,
  }) : super(key: key);
  final String imageUrl;
  final BoxConstraints constraints;
  final bool isDocked;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    final backgroundPane = ColoredBox(
      color: R.colors.swipeCardBackground,
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
      duration: transitionDuration,
      width: constraints.maxWidth,
      height:
          isDocked ? constraints.maxHeight / 4 : 2 * constraints.maxHeight / 3,
      decoration: const BoxDecoration(),
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: isDocked
          ? const BoxDecoration()
          : BoxDecoration(
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
