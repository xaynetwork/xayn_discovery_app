import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
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
  late final Map<Document, _CardManagers> _cardManagers;

  int _totalResults = 0;
  double _dragDistance = .0;

  @override
  NavBarConfig get navBarConfig => NavBarConfig([
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
      ]);

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
      body: _buildFeedView(),
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
    _cardManagers = <Document, _CardManagers>{};

    WidgetsBinding.instance!.addObserver(this);

    super.initState();
  }

  Widget _buildFeedView() =>
      BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
        bloc: _discoveryFeedManager,
        builder: (context, state) {
          final results = state.results;
          final scrollDirection = state.axis.axis;
          final isSwipingEnabled = scrollDirection == Axis.vertical;

          if (results == null) {
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
            onFinalIndex: _discoveryFeedManager.handleLoadMore,
            onIndexChanged: _discoveryFeedManager.handleIndexChanged,
            isFullScreen: state.isFullScreen,
            fullScreenOffsetFraction: _dragDistance / kDragThreshold,
          );
        },
      );

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
              )
            : InkWell(
                onTap: _discoveryFeedManager.handleNavigateIntoCard,
                child: DiscoveryFeedCard(
                  isPrimary: isPrimary,
                  document: document,
                  discoveryCardManager: managers.discoveryCardManager,
                  imageManager: managers.imageManager,
                ),
              );

        return _ResultCard(
          document: document,
          card: card,
          isPrimary: isPrimary,
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

class _ResultCard extends StatelessWidget {
  final bool isPrimary;
  final Document document;
  final Widget card;
  final bool isSwipingEnabled;

  const _ResultCard({
    Key? key,
    required this.isPrimary,
    required this.document,
    required this.card,
    required this.isSwipingEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final swipeCard = SwipeableDiscoveryCard(
      isPrimary: isPrimary,
      document: document,
      card: card,
      isSwipingEnabled: isSwipingEnabled,
    );

    return swipeCard;
  }
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
