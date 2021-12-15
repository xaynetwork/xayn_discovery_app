import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/images/manager/image_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/discovery_feed_scroll_direction_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/button/temp_button.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed>
    with WidgetsBindingObserver {
  late final CardViewController _cardViewController;
  late final DiscoveryFeedManager _discoveryFeedManager;
  late final Expando<_CardManagers> _cardManagers;

  int _totalResults = 0;
  double _dragDistance = .0;

  @override
  Widget build(BuildContext context) {
    final bottomNav = Positioned(
      bottom: MediaQuery.of(context).padding.bottom + R.dimen.unit2,
      child: Row(
        children: [
          TempButton(
            iconName: R.assets.icons.search,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActiveSearch(),
              ),
            ),
          ),
          SizedBox(width: R.dimen.unit),
          TempButton(
            iconName: R.assets.icons.gear,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            _buildFeedView(),
            bottomNav,
          ],
        ),
      ),
    );
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
  void dispose() {
    _cardViewController.dispose();
    _discoveryFeedManager.close();

    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    _cardViewController = CardViewController();
    _discoveryFeedManager = di.get();
    _cardManagers = Expando<_CardManagers>();

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
        final managers = _cardManagers[document];
        final discoveryCardManager = managers?.discoveryCardManager;
        final imageManager = managers?.imageManager;
        final card = isFullScreen
            ? DiscoveryCard(
                isPrimary: true,
                document: document,
                discoveryCardManager: discoveryCardManager,
                imageManager: imageManager,
                onDiscard: _discoveryFeedManager.handleNavigateOutOfCard,
                onDrag: _onFullScreenDrag,
              )
            : DiscoveryFeedCard(
                isPrimary: isPrimary,
                document: document,
                discoveryCardManager: discoveryCardManager,
                imageManager: imageManager,
                onTap: _discoveryFeedManager.handleNavigateIntoCard,
                onCardManager: (manager) =>
                    _cardManagers[document] = _CardManagers(
                  discoveryCardManager: manager,
                  imageManager: imageManager,
                ),
                onImageManager: (manager) =>
                    _cardManagers[document] = _CardManagers(
                  discoveryCardManager: discoveryCardManager,
                  imageManager: manager,
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
}

class _ResultCard extends StatelessWidget {
  final bool isPrimary;
  final Document document;
  final DiscoveryCardBase card;
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
  final DiscoveryCardManager? discoveryCardManager;
  final ImageManager? imageManager;

  const _CardManagers({
    this.imageManager,
    this.discoveryCardManager,
  });
}
