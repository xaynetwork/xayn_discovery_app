import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';

/// A widget which displays a list of discovery results,
/// and has an ability to perform search.
class ActiveSearch extends StatefulWidget {
  const ActiveSearch({Key? key}) : super(key: key);

  @override
  _ActiveSearchState createState() => _ActiveSearchState();
}

class _ActiveSearchState extends State<ActiveSearch> with NavBarConfigMixin {
  late final ActiveSearchManager _activeSearchManager;

  @override
  NavBarConfig get navBarConfig => NavBarConfig(
        [
          buildNavBarItemHome(
            onPressed: _activeSearchManager.onHomeNavPressed,
          ),
          buildNavBarItemSearchActive(
            onSearchPressed: _activeSearchManager.handleSearch,
            hint: Strings.activeSearchSearchHint,
            isActive: true,
          ),
          buildNavBarItemAccount(
            onPressed: _activeSearchManager.onAccountNavPressed,
          )
        ],
        showAboveKeyboard: true,
      );

  @override
  void initState() {
    _activeSearchManager = di.get();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFeedView(),
    );
  }

  Widget _buildFeedView() {
    return BlocBuilder<ActiveSearchManager, ActiveSearchState>(
      bloc: _activeSearchManager,
      builder: (context, state) {
        final results = state.results ?? [];

        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (results.isEmpty) {
          return Container();
        }

        return FeedView(
          itemBuilder: _itemBuilder(results, true),
          secondaryItemBuilder: _itemBuilder(results, false),
          itemCount: results.length,
          isFullScreen: false,
        );
      },
    );
  }

  Widget Function(BuildContext, int) _itemBuilder(
    List<Document> results,
    bool isPrimary,
  ) =>
      (BuildContext context, int index) {
        final document = results[index];
        return _buildResultCard(
          document,
          isPrimary,
        );
      };

  Widget _buildResultCard(
    Document document,
    bool isPrimary,
  ) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit,
          vertical: R.dimen.unit0_5,
        ),
        child: DiscoveryFeedCard(
          isPrimary: isPrimary,
          document: document,
        ),
      );
}
