import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_manager.dart';
import 'package:xayn_discovery_app/presentation/active_search/manager/active_search_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/widget/feed_view.dart';
import 'package:xayn_discovery_app/presentation/widget/temp_search_bar.dart';

/// A widget which displays a list of discovery results,
/// and has an ability to perform search.
class ActiveSearch extends StatefulWidget {
  const ActiveSearch({Key? key}) : super(key: key);

  @override
  _ActiveSearchState createState() => _ActiveSearchState();
}

class _ActiveSearchState extends State<ActiveSearch> {
  late final ActiveSearchManager _activeSearchManager;

  @override
  void initState() {
    _activeSearchManager = di.get();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNav = Positioned(
      bottom: MediaQuery.of(context).padding.bottom + R.dimen.unit2,
      left: R.dimen.unit2,
      right: R.dimen.unit2,
      child: TempSearchBar(
        onSearch: (term) => _activeSearchManager.handleSearch(term),
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
          itemBuilder: _itemBuilder(results),
          itemCount: results.length,
        );
      },
    );
  }

  Widget Function(BuildContext, int) _itemBuilder(List<Document> results) =>
      (BuildContext context, int index) {
        final document = results[index];
        return _buildResultCard(document);
      };

  Widget _buildResultCard(Document document) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit,
          vertical: R.dimen.unit0_5,
        ),
        child: DiscoveryCard(
          title: document.webResource.title,
          snippet: document.webResource.snippet,
          imageUrl: document.webResource.displayUrl.toString(),
          url: document.webResource.url,
        ),
      );
}
