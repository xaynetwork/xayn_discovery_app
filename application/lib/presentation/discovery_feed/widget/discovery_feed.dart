import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';

abstract class DiscoveryFeedNavActions {
  void onSearchNavPressed();

  void onAccountNavPressed();
}

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed>
    with WidgetsBindingObserver, NavBarConfigMixin {
  late final CardViewController _cardViewController;
  late final DiscoveryFeedManager _discoveryFeedManager;
  late final DiscoveryCardActionsManager _discoveryCardActionsManager;
  late final Map<Document, _CardManagers> _cardManagers;
  DiscoveryCardController? _currentCardController;

  int _totalResults = 0;
  double _dragDistance = .0;

  @override
  NavBarConfig get navBarConfig {
    if (_discoveryFeedManager.state.results == null) {
      return NavBarConfig.hidden();
    }

    final document = _discoveryFeedManager
        .state.results![_discoveryFeedManager.state.resultIndex];
    final defaultNavBarConfig = NavBarConfig(
      [
        buildNavBarItemHome(
          isActive: true,
          onPressed: _discoveryFeedManager.onHomeNavPressed,
        ),
        buildNavBarItemSearch(
          onPressed: _discoveryFeedManager.onSearchNavPressed,
        ),
        buildNavBarItemAccount(
          onPressed: _discoveryFeedManager.onAccountNavPressed,
        ),
      ],
    );
    final readerModeNavBarConfig = NavBarConfig(
      [
        buildNavBarItemArrowLeft(onPressed: () async {
          await _currentCardController?.animateToClose();

          _discoveryFeedManager.handleNavigateOutOfCard();
        }),
        buildNavBarItemLike(
          isLiked: document.isRelevant,
          onPressed: () => _discoveryCardActionsManager.likeDocument(document),
        ),
        buildNavBarItemShare(
          onPressed: () =>
              _discoveryCardActionsManager.shareUri(document.webResource.url),
        ),
        buildNavBarItemDisLike(
          isDisLiked: document.isNotRelevant,
          onPressed: () =>
              _discoveryCardActionsManager.dislikeDocument(document),
        ),
      ],
      isWidthExpanded: true,
    );

    return _discoveryFeedManager.state.isFullScreen
        ? readerModeNavBarConfig
        : defaultNavBarConfig;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        return _discoveryFeedManager.handleActivityStatus(true);
      default:
        return _discoveryFeedManager.handleActivityStatus(false);
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
    _discoveryFeedManager.close();

    WidgetsBinding.instance!.removeObserver(this);

    _cardManagers
      ..forEach((_, managers) => managers.closeAll())
      ..clear();

    super.dispose();
  }

  @override
  void initState() {
    _cardViewController = CardViewController();
    _discoveryFeedManager = di.get();
    _discoveryCardActionsManager = di.get();
    _cardManagers = <Document, _CardManagers>{};

    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  Widget _buildFeedView() => LayoutBuilder(builder: (context, constraints) {
        // transform the cardNotchSize to a fractional value between [0.0, 1.0]
        final notchSize = 1.0 - R.dimen.cardNotchSize / constraints.maxHeight;

        return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
          bloc: _discoveryFeedManager,
          builder: (context, state) {
            final results = state.results;

            NavBarContainer.updateNavBar(context);

            if (results == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            _totalResults = results.length;

            return FeedView(
              cardViewController: _cardViewController,
              itemBuilder: _itemBuilder(
                results: results,
                isPrimary: true,
                isSwipingEnabled: true,
                isFullScreen: state.isFullScreen,
              ),
              secondaryItemBuilder: _itemBuilder(
                results: results,
                isPrimary: false,
                isSwipingEnabled: true,
                isFullScreen: false,
              ),
              itemCount: _totalResults,
              onFinalIndex: _discoveryFeedManager.handleLoadMore,
              onIndexChanged: _discoveryFeedManager.handleIndexChanged,
              isFullScreen: state.isFullScreen,
              fullScreenOffsetFraction:
                  _dragDistance / DiscoveryCard.dragThreshold,
              notchSize: notchSize,
            );
          },
        );
      });

  Widget Function(BuildContext, int) _itemBuilder({
    required List<Document> results,
    required bool isPrimary,
    required bool isSwipingEnabled,
    required bool isFullScreen,
  }) =>
      (BuildContext context, int index) {
        final document = results[index];
        final managers = managersOf(document);

        if (isPrimary) {
          _discoveryFeedManager.handleViewType(
            document,
            isFullScreen ? DocumentViewType.readerMode : DocumentViewType.story,
          );
        }

        final card = isFullScreen
            ? DiscoveryCard(
                isPrimary: true,
                document: document,
                discoveryCardManager: managers.discoveryCardManager,
                imageManager: managers.imageManager,
                onDiscard: _discoveryFeedManager.handleNavigateOutOfCard,
                onDrag: _onFullScreenDrag,
                onController: (controller) =>
                    _currentCardController = controller,
              )
            : GestureDetector(
                onTap: _discoveryFeedManager.handleNavigateIntoCard,
                child: DiscoveryFeedCard(
                  isPrimary: isPrimary,
                  document: document,
                  discoveryCardManager: managers.discoveryCardManager,
                  imageManager: managers.imageManager,
                ),
              );

        return SwipeableDiscoveryCard(
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
