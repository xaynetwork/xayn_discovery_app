import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
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
import 'package:xayn_discovery_app/presentation/widget/button/temp_button.dart';

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed> {
  late final CardViewController _cardViewController;
  late final DiscoveryFeedManager _discoveryFeedManager;

  int _totalResults = 0;

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
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          _buildFeedView(),
          bottomNav,
        ],
      ),
    );
  }

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
