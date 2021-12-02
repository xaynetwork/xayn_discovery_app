import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/swipeable_discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/discovery_feed_scroll_direction_extension.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/nav_bar_items.dart';

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed> with NavBarConfigMixin {
  late final CardViewController _cardViewController;
  late final DiscoveryFeedManager _discoveryFeedManager;

  int _totalResults = 0;

  @override
  NavBarConfig get navBarConfig => NavBarConfig([
        buildNavBarItemHome(
          isActive: true,
          onPressed: () {},
        ),
        buildNavBarItemSearch(
          onPressed: () => _openScreen(const ActiveSearch(), true),
        ),
        buildNavBarItemAccount(
          onPressed: () => _openScreen(const SettingsScreen(), false),
        )
      ]);

  @override
  void initState() {
    _cardViewController = CardViewController();
    _discoveryFeedManager = di.get();

    super.initState();
  }

  @override
  void dispose() {
    _cardViewController.dispose();
    _discoveryFeedManager.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _buildFeedView(),

        /// This is for testing purposes only
        /// Should be removed once we have a settings page
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              UnterDenLinden.of(context).changeBrightness(R.invertedBrightness),
          tooltip: 'Toggle Theme',
          child: const Icon(Icons.theater_comedy),
        ),
      );

  Widget Function(BuildContext, int) _itemBuilder({
    required List<Document> results,
    required bool isPrimary,
    required bool isSwipingEnabled,
  }) =>
      (BuildContext context, int index) {
        final document = results[index];

        return _ResultCard(
          document: document,
          isPrimary: isPrimary,
          isSwipingEnabled: isSwipingEnabled,
        );
      };

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
              isSwipingEnabled: isSwipingEnabled,
            ),
            secondaryItemBuilder: _itemBuilder(
              results: results,
              isPrimary: false,
              isSwipingEnabled: isSwipingEnabled,
            ),
            itemCount: _totalResults,
            onFinalIndex: _discoveryFeedManager.handleLoadMore,
          );
        },
      );

  void _openScreen(Widget screen, bool replace) {
    final route = MaterialPageRoute(builder: (context) => screen);
    if (replace) {
      Navigator.pushReplacement(
        context,
        route,
      );
    } else {
      Navigator.push(
        context,
        route,
      );
    }
  }
}

class _ResultCard extends StatelessWidget {
  final bool isPrimary;
  final Document document;
  final bool isSwipingEnabled;

  const _ResultCard({
    Key? key,
    required this.isPrimary,
    required this.document,
    required this.isSwipingEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = SwipeableDiscoveryCard(
      isPrimary: isPrimary,
      document: document,
      isSwipingEnabled: isSwipingEnabled,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.dimen.unit,
        vertical: R.dimen.unit0_5,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.dimen.unit1_5),
        child: card,
      ),
    );
  }
}
