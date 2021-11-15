import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/button/temp_search_button.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

enum SwipeOption { like, share, dislike }

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed> {
  late final ScrollController _scrollController;
  late final DiscoveryFeedManager _discoveryFeedManager;

  @override
  void initState() {
    _scrollController = ScrollController();
    _discoveryFeedManager = di.get();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset != .0) {
        _discoveryFeedManager.loadMore();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNav = Positioned(
      bottom: MediaQuery.of(context).padding.bottom + R.dimen.unit2,
      child: TempSearchButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActiveSearch()),
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

  Widget Function(BuildContext, int) _itemBuilder(List<Document> results) =>
      (BuildContext context, int index) {
        final document = results[index];
        return _buildResultCard(document);
      };

  Widget _buildFeedView() {
    return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
      bloc: _discoveryFeedManager,
      builder: (context, state) {
        final results = state.results ?? [];

        if (results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return FeedView(
          scrollController: _scrollController,
          itemBuilder: _itemBuilder(results),
          itemCount: results.length,
        );
      },
    );
  }

  Widget _buildSwipeWidget({required Widget child}) => Swipe(
        optionsLeft: const [SwipeOption.like, SwipeOption.share],
        optionsRight: const [SwipeOption.dislike],
        onFling: (options) => options.first,
        child: child,
        optionBuilder: (context, option, index, selected) {
          return SwipeOptionContainer(
            option: option,
            color: option == SwipeOption.dislike
                ? R.colors.swipeBackgroundDelete
                : option == SwipeOption.like
                    ? R.colors.swipeBackgroundRelevant
                    : R.colors.swipeBackgroundShare,
            child: option == SwipeOption.dislike
                ? const Icon(Icons.close)
                : option == SwipeOption.like
                    ? const Icon(Icons.verified)
                    : const Icon(Icons.share),
          );
        },
      );

  Widget _buildResultCard(Document document) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit,
          vertical: R.dimen.unit0_5,
        ),
        child: _buildSwipeWidget(
          child: DiscoveryCard(
            title: document.webResource.title,
            snippet: document.webResource.snippet,
            imageUrl: document.webResource.displayUrl.toString(),
            url: document.webResource.url,
          ),
        ),
      );
}
