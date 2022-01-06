import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/discovery_feed_scroll_direction_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

abstract class DiscoveryFeedNavActions {
  void onSearchNavPressed();

  void onAccountNavPressed();
}

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  final DiscoveryFeedManager manager;

  const DiscoveryFeed({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed>
    with WidgetsBindingObserver, NavBarConfigMixin {
  late final _cardViewController = CardViewController();
  late final Map<Document, _CardManagers> _cardManagers = {};
  DiscoveryCardController? _currentCardController;

  int _totalResults = 0;
  double _dragDistance = .0;

  @override
  NavBarConfig get navBarConfig {
    NavBarConfig buildDefault() => NavBarConfig(
          [
            buildNavBarItemHome(
              isActive: true,
              onPressed: widget.manager.onHomeNavPressed,
            ),
            buildNavBarItemSearch(
              onPressed: widget.manager.onSearchNavPressed,
            ),
            buildNavBarItemAccount(
              onPressed: widget.manager.onAccountNavPressed,
            ),
          ],
        );
    NavBarConfig buildReaderMode() {
      final document = widget.manager.state.results
          .elementAt(widget.manager.state.resultIndex);
      final managers = managersOf(document);

      return NavBarConfig(
        [
          buildNavBarItemArrowLeft(onPressed: () async {
            await _currentCardController?.animateToClose();

            widget.manager.handleNavigateOutOfCard();
          }),
          buildNavBarItemLike(
            isLiked: document.isRelevant,
            onPressed: () =>
                managers.discoveryCardManager.changeDocumentFeedback(
              documentId: document.documentId,
              feedback: DocumentFeedback.positive,
            ),
          ),
          buildNavBarItemShare(
            onPressed: () => managers.discoveryCardManager
                .shareUri(document.webResource.url),
          ),
          buildNavBarItemDisLike(
            isDisLiked: document.isIrrelevant,
            onPressed: () =>
                managers.discoveryCardManager.changeDocumentFeedback(
              documentId: document.documentId,
              feedback: DocumentFeedback.negative,
            ),
          ),
        ],
        isWidthExpanded: true,
      );
    }

    return widget.manager.state.isFullScreen
        ? buildReaderMode()
        : buildDefault();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return widget.manager.handleActivityStatus(true);
      default:
        return widget.manager.handleActivityStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _buildFeedView(),
      ),
    );
  }

  @override
  void dispose() {
    _cardViewController.dispose();
    widget.manager.close();

    WidgetsBinding.instance!.removeObserver(this);

    _cardManagers
      ..forEach((_, managers) => managers.closeAll())
      ..clear();

    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  Widget _buildFeedView() => LayoutBuilder(builder: (context, constraints) {
        // transform the cardNotchSize to a fractional value between [0.0, 1.0]
        final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;

        var isInReaderMode = widget.manager.state.isFullScreen;
        return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
          bloc: widget.manager,
          builder: (context, state) {
            final results = state.results;
            final scrollDirection = state.axis.axis;
            final isSwipingEnabled = scrollDirection == Axis.vertical;

            if (isInReaderMode != state.isFullScreen) {
              // we need to update NavBarConfig ONLY WHEN we change this flag
              isInReaderMode = !isInReaderMode;
              NavBarContainer.updateNavBar(context);
            }

            if (results.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            _totalResults = results.length;

            return FeedView(
              scrollDirection: scrollDirection,
              cardViewController: _cardViewController,
              itemBuilder: _itemBuilder(
                results: results,
                isPrimary: true,
                isSwipingEnabled: state.isFullScreen ? false : isSwipingEnabled,
                isFullScreen: state.isFullScreen,
              ),
              secondaryItemBuilder: _itemBuilder(
                results: results,
                isPrimary: false,
                isSwipingEnabled: isSwipingEnabled,
                isFullScreen: false,
              ),
              itemCount: _totalResults,
              onFinalIndex: widget.manager.handleLoadMore,
              onIndexChanged: widget.manager.handleIndexChanged,
              isFullScreen: state.isFullScreen,
              fullScreenOffsetFraction:
                  _dragDistance / DiscoveryCard.dragThreshold,
              notchSize: notchSize,
            );
          },
        );
      });

  Widget Function(BuildContext, int) _itemBuilder({
    required Set<Document> results,
    required bool isPrimary,
    required bool isSwipingEnabled,
    required bool isFullScreen,
  }) =>
      (BuildContext context, int index) {
        final document = results.elementAt(index);
        final managers = managersOf(document);

        if (isPrimary) {
          widget.manager.handleViewType(
            document,
            isFullScreen ? DocumentViewMode.reader : DocumentViewMode.story,
          );
        }

        final card = isFullScreen
            ? DiscoveryCard(
                isPrimary: true,
                document: document,
                discoveryCardManager: managers.discoveryCardManager,
                imageManager: managers.imageManager,
                onDiscard: widget.manager.handleNavigateOutOfCard,
                onDrag: _onFullScreenDrag,
                onController: (controller) =>
                    _currentCardController = controller,
              )
            : GestureDetector(
                onTap: widget.manager.handleNavigateIntoCard,
                child: DiscoveryFeedCard(
                  isPrimary: isPrimary,
                  document: document,
                  discoveryCardManager: managers.discoveryCardManager,
                  imageManager: managers.imageManager,
                ),
              );

        return SwipeableDiscoveryCard(
          manager: managers.discoveryCardManager,
          isPrimary: isPrimary,
          document: document,
          card: card,
          isSwipingEnabled: isSwipingEnabled,
        );
      };

  void _onFullScreenDrag(double distance) {
    setState(() {
      _dragDistance = distance;
    });
  }

  _CardManagers managersOf(Document document) => _cardManagers.putIfAbsent(
      document,
      () => _CardManagers(
            imageManager: di.get()
              ..getImage(Uri.parse(document.webResource.displayUrl.toString())),
            discoveryCardManager: di.get()..updateUri(document.webResource.url),
          ));
}

@immutable
class _CardManagers {
  final DiscoveryCardManager discoveryCardManager;
  final ImageManager imageManager;

  const _CardManagers({
    required this.imageManager,
    required this.discoveryCardManager,
  });

  void closeAll() {
    imageManager.close();
    discoveryCardManager.close();
  }
}
