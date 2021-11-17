import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_footer.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/scroll_physics/custom_page_scroll_physics.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/search_events.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';
import 'package:share/share.dart';

enum SwipeOption { like, share, dislike }

/// A widget which displays a list of discovery results.
class DiscoveryFeed extends StatefulWidget {
  const DiscoveryFeed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DiscoveryFeedState();
}

class _DiscoveryFeedState extends State<DiscoveryFeed> {
  late final DiscoveryEngineManager _discoveryEngineManager;
  late final ScrollController _scrollController;
  late final DiscoveryFeedManager _discoveryFeedManager;
  ValueNotifier<int> visibleIndex = ValueNotifier(0);

  @override
  void initState() {
    _scrollController = ScrollController();
    _discoveryEngineManager = di.get();
    _discoveryFeedManager = di.get();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.offset != .0) {
        _discoveryEngineManager.onClientEvent
            .add(const SearchRequested('', [SearchType.web]));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
      bloc: _discoveryFeedManager,
      builder: (context, state) {
        final results = state.results;

        if (results == null) {
          return const CircularProgressIndicator();
        }

        final padding = MediaQuery.of(context).padding;

        return Padding(
          padding: EdgeInsets.only(top: padding.top),
          child: LayoutBuilder(builder: (context, constraints) {
            final pageSize =
                constraints.maxHeight - padding.bottom - R.dimen.unit3;
            final physics = CustomPageScrollPhysics(pageSize: pageSize);

            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemExtent: pageSize,
                physics: physics,
                scrollDirection: Axis.vertical,
                controller: _scrollController,
                itemBuilder: _itemBuilder(results),
                itemCount: results.length,
              ),
            );
          }),
        );
      },
    );
  }

  Widget Function(BuildContext, int) _itemBuilder(List<Document> results) =>
      (BuildContext context, int index) {
        final document = results[index];
        return _buildResultCard(document);
      };

  Widget _buildSwipeWidget({required Widget child}) => Swipe(
        optionsLeft: const [SwipeOption.like],
        optionsRight: const [SwipeOption.dislike],
        onFling: (options) => options.first,
        opensToPosition: 0.35,
        child: child,
        optionBuilder: (context, option, index, selected) {
          return SwipeOptionContainer(
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
          );
        },
      );

  Widget _buildResultCard(Document document) {
    final actionButtonRow = ButtonRowFooter(
      onSharePressed: () => Share.share(document.webResource.url.toString()),
      onLikePressed: () => debugPrint('Like is pressed'),
      onDislikePressed: () => debugPrint('Dislike is pressed'),
    );
    final footer = DiscoveryCardFooter(
      title: document.webResource.title,
      provider: document.webResource.provider,
      datePublished: document.webResource.datePublished,
      actionButtonRow: actionButtonRow,
      onFooterPressed: () => debugPrint('Open article'),
    );
    final card = DiscoveryCard(
      snippet: document.webResource.snippet,
      imageUrl: document.webResource.displayUrl.toString(),
      url: document.webResource.url,
      footer: footer,
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.dimen.unit,
        vertical: R.dimen.unit0_5,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.dimen.unit1_5),
        child: _buildSwipeWidget(
          child: card,
        ),
      ),
    );
  }
}
