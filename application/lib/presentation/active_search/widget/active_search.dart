import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/nav_bar_items.dart';

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
  NavBarConfig get navBarConfig => NavBarConfig([
        buildNavBarItemHome(
          onPressed: () => _openScreen(const DiscoveryFeed(), true),
        ),
        buildNavBarItemSearchActive(
          onSearchPressed: _activeSearchManager.handleSearch,
        ),
        buildNavBarItemAccount(
          onPressed: () => _openScreen(const SettingsScreen(), false),
        )
      ]);

  @override
  void initState() {
    _activeSearchManager = di.get();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _buildFeedView(),
      );

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
        child: DiscoveryCard(
          isPrimary: isPrimary,
          document: document,
        ),
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
