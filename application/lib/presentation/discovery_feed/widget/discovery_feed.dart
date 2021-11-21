import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_card_view/xayn_card_view.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/button/temp_search_button.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

enum SwipeOption { like, dislike }

const kSwipeOpenToPosition = 0.35;

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

    _cardViewController.addListener(() {
      if (_cardViewController.index == _totalResults - 1) {
        _discoveryFeedManager.handleLoadMore();
      }
    });

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
      child: TempSearchButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ActiveSearch(),
          ),
        ),
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

  Widget Function(BuildContext, int) _itemBuilder(
    List<Document> results,
    bool isPrimary,
  ) =>
      (BuildContext context, int index) {
        final document = results[index];
        return _ResultCard(
          key: isPrimary ? Key(document.webResource.url.toString()) : null,
          document: document,
          isPrimary: isPrimary,
        );
      };

  Widget _buildFeedView() =>
      BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
        bloc: _discoveryFeedManager,
        builder: (context, state) {
          final results = state.results;

          if (results == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          _totalResults = results.length;

          return FeedView(
            cardViewController: _cardViewController,
            itemBuilder: _itemBuilder(results, true),
            secondaryItemBuilder: _itemBuilder(results, false),
            itemCount: _totalResults,
          );
        },
      );
}

class _ResultCard extends AutomaticKeepAlive {
  final bool isPrimary;
  final Document document;

  const _ResultCard({
    Key? key,
    required this.isPrimary,
    required this.document,
  }) : super(key: key);

  @override
  State<AutomaticKeepAlive> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  @override
  Widget build(BuildContext context) {
    final card = DiscoveryCard(
      isPrimary: widget.isPrimary,
      webResource: widget.document.webResource,
    );
    final child = widget.isPrimary ? _buildSwipeWidget(child: card) : card;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.dimen.unit,
        vertical: R.dimen.unit0_5,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.dimen.unit1_5),
        child: child,
      ),
    );
  }

  Widget _buildSwipeWidget({required Widget child}) => Swipe(
        optionsLeft: const [SwipeOption.like],
        optionsRight: const [SwipeOption.dislike],
        onFling: (options) => options.first,
        opensToPosition: kSwipeOpenToPosition,
        child: child,
        optionBuilder: (context, option, index, selected) =>
            SwipeOptionContainer(
          option: option,
          color: option == SwipeOption.dislike
              ? R.colors.swipeBackgroundDelete
              : R.colors.swipeBackgroundRelevant,
          child: option == SwipeOption.dislike
              ? SvgPicture.asset(
                  R.assets.icons.thumbsDown,
                  fit: BoxFit.none,
                  color: R.colors.brightIcon,
                )
              : SvgPicture.asset(
                  R.assets.icons.thumbsUp,
                  fit: BoxFit.none,
                  color: R.colors.brightIcon,
                ),
        ),
      );
}
