import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/dicovery_feed_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/utils/card_managers_mixin.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

const double kSearchCardHeightRatio = 0.64;

/// A widget which displays a list of discovery results,
/// and has an ability to perform search.
class ActiveSearch extends StatefulWidget {
  const ActiveSearch({Key? key}) : super(key: key);

  @override
  _ActiveSearchState createState() => _ActiveSearchState();
}

class _ActiveSearchState extends State<ActiveSearch>
    with NavBarConfigMixin, CardManagersMixin {
  late final ActiveSearchManager _activeSearchManager = di.get();

  @override
  NavBarConfig get navBarConfig => NavBarConfig(
        [
          buildNavBarItemHome(
            onPressed: _activeSearchManager.onHomeNavPressed,
          ),
          buildNavBarItemSearchActive(
            onSearchPressed: _activeSearchManager.search,
            hint: R.strings.activeSearchSearchHint,
            isActive: true,
          ),
          buildNavBarItemPersonalArea(
            onPressed: _activeSearchManager.onPersonalAreaNavPressed,
          )
        ],
        showAboveKeyboard: true,
      );

  @override
  void dispose() {
    _activeSearchManager.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildListView(),
    );
  }

  Widget _buildListView() {
    return LayoutBuilder(builder: (context, constraints) {
      final cardHeight = constraints.maxHeight * kSearchCardHeightRatio;

      return BlocBuilder<ActiveSearchManager, ActiveSearchState>(
        bloc: _activeSearchManager,
        builder: (context, state) {
          final results = state.results ?? {};

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (results.isEmpty) {
            return Container();
          }

          return ListView.builder(
            itemBuilder: _itemBuilder(results, true),
            itemCount: results.length,
            itemExtent: cardHeight,
          );
        },
      );
    });
  }

  Widget Function(BuildContext, int) _itemBuilder(
    Set<Document> results,
    bool isPrimary,
  ) =>
      (BuildContext context, int index) {
        final document = results.elementAt(index);
        return _buildResultCard(
          document,
          isPrimary,
        );
      };

  Widget _buildResultCard(
    Document document,
    bool isPrimary,
  ) {
    final managers = managersOf(document);
    final card = GestureDetector(
      onTap: () {
        final args = DiscoveryCardScreenArgs(
          isPrimary: true,
          document: document,
        );
        _activeSearchManager.onCardDetailsPressed(args);
      },
      child: DiscoveryFeedCard(
        isPrimary: isPrimary,
        document: document,
        imageManager: managers.imageManager,
        discoveryCardManager: managers.discoveryCardManager,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.dimen.unit,
        vertical: R.dimen.unit0_5,
      ),
      child: ClipRRect(
        child: card,
        borderRadius: BorderRadius.circular(R.dimen.unit1_5),
      ),
    );
  }
}
