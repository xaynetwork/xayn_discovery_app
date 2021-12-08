import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/heroes.dart'
    as heroes;
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/shared_card_image.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_body.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/reader_mode_screen.dart';
import 'package:xayn_readability/xayn_readability.dart' hide ReaderMode;

import 'discovery_card_footer.dart';

typedef ViewTypeCallback = void Function(DocumentViewType viewType);

/// A widget which displays a discovery card.
class DiscoveryCard extends StatefulWidget {
  final bool isPrimary;
  final Document document;
  final int cardIndex;
  final ViewTypeCallback? onViewTypeChanged;

  const DiscoveryCard({
    Key? key,
    required this.isPrimary,
    required this.document,
    required this.cardIndex,
    this.onViewTypeChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryCardState();
}

class _DiscoveryCardState extends State<DiscoveryCard> {
  late final DiscoveryCardManager _discoveryCardManager;
  late final ImageManager _imageManager;
  late final NavigatorState _navigator;
  late final SharedCardImageController _sharedCardImageController;

  WebResource get webResource => widget.document.webResource;
  Uri get url => webResource.url;
  String get imageUrl => webResource.displayUrl.toString();
  String get snippet => webResource.snippet;

  @override
  void initState() {
    super.initState();

    _discoveryCardManager = di.get();
    _imageManager = di.get()..getImage(Uri.parse(imageUrl));
    _sharedCardImageController = SharedCardImageController(1.0);
    _navigator = Navigator.of(context);

    widget.onViewTypeChanged?.call(DocumentViewType.story);
  }

  @override
  void didUpdateWidget(DiscoveryCard oldWidget) {
    if (oldWidget.document != widget.document) {
      _imageManager = di.get()..getImage(Uri.parse(imageUrl));
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();

    _discoveryCardManager.close();
    _imageManager.close();
    _sharedCardImageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPrimary) {
      _discoveryCardManager.updateUri(url);
    }

    return BlocBuilder<DiscoveryCardManager, DiscoveryCardState>(
        bloc: _discoveryCardManager,
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) => _buildCardDisplayStack(
              isPrimary: widget.isPrimary,
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
    ProcessHtmlResult? processHtmlResult,
  }) {
    final DiscoveryCardActionsManager _actionsManager = di.get();

    final allSnippets = isPrimary ? [snippet, ...snippets] : [snippet];
    final fullSize = constraints.maxHeight;
    final heroTag = '${heroes.cardImageTag}_${widget.cardIndex}';

    // todo: swap for the real navigation later on
    final route = PageRouteBuilder(
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) =>
          AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          _sharedCardImageController.value = 1.0 - animation.value;

          return Opacity(opacity: sqrt(animation.value), child: child);
        },
      ),
      transitionDuration: R.durations.tweenIntoReaderModeDuration,
      reverseTransitionDuration: R.durations.tweenIntoReaderModeDuration,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        _,
      ) =>
          ReaderModeScreen(
        document: widget.document,
        heroTag: heroTag,
        animation: animation,
        discoveryCardManager: _discoveryCardManager,
        imageManager: _imageManager,
        sharedCardImageController: _sharedCardImageController,
      ),
    );

    final cardBackground = _CardBackground(
      imageUrl: imageUrl,
      imageManager: _imageManager,
      heroTag: heroTag,
      constraints: constraints,
      sharedCardImageController: _sharedCardImageController,
    );
    final footer = DiscoveryCardFooter(
      title: webResource.title,
      url: webResource.url,
      provider: webResource.provider,
      datePublished: webResource.datePublished,
      onFooterPressed: () => _navigator.push(route),
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
      cardBackground,
      bodyAndFooter,
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
}

class _CardBackground extends StatelessWidget {
  const _CardBackground({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
    required this.constraints,
    required this.imageManager,
    required this.sharedCardImageController,
  }) : super(key: key);
  final String imageUrl;
  final String heroTag;
  final BoxConstraints constraints;
  final ImageManager imageManager;
  final SharedCardImageController sharedCardImageController;

  @override
  Widget build(BuildContext context) {
    final backgroundPane = ColoredBox(
      color: R.colors.swipeCardBackground,
    );

    final isImageNotAvailable = !imageUrl.startsWith('http');

    final backgroundImage = isImageNotAvailable
        ? backgroundPane
        : Hero(
            tag: heroTag,
            child: SharedCardImage(
              uri: Uri.parse(imageUrl),
              imageManager: imageManager,
              controller: sharedCardImageController,
            ),
          );

    return isImageNotAvailable ? backgroundPane : backgroundImage;
  }
}
