import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/feed_view.dart';

class ActiveSearch extends StatefulWidget {
  const ActiveSearch({Key? key}) : super(key: key);

  @override
  _ActiveSearchState createState() => _ActiveSearchState();
}

class _ActiveSearchState extends State<ActiveSearch> {
  late final DiscoveryEngineManager _discoveryEngineManager;
  late final DiscoveryFeedManager _discoveryFeedManager;

  @override
  void initState() {
    _discoveryEngineManager = di.get();
    _discoveryFeedManager = di.get();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFeedView(),
    );
  }

  Widget _buildFeedView() {
    return BlocBuilder<DiscoveryFeedManager, DiscoveryFeedState>(
      bloc: _discoveryFeedManager,
      builder: (context, state) {
        final results = state.results ?? [];

        if (results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
