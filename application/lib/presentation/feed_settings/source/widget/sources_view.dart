import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/widget/source_list_item.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class SourcesView extends StatelessWidget {
  final SourcesManager manager;
  final SourcesState state;
  final Set<Source> sources;
  final SourceType sourceType;

  SourcesView.excludedSources({
    Key? key,
    required this.manager,
    required this.state,
  })  : sourceType = SourceType.excluded,
        sources = state.jointExcludedSources,
        super(key: key);

  SourcesView.trustedSources({
    Key? key,
    required this.manager,
    required this.state,
  })  : sourceType = SourceType.trusted,
        sources = state.jointTrustedSources,
        super(key: key);

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemBuilder: (context, index) {
          final source = sources.elementAt(index);

          return _createItem(context, source);
        },
        itemCount: sources.length,
        padding: EdgeInsets.only(bottom: R.dimen.navBarHeight * 2),
      );

  Widget _createItem(BuildContext context, Source source) {
    final isPendingRemoval =
            manager.isPendingRemoval(source: source, scope: sourceType),
        isPendingAddition =
            manager.isPendingAddition(source: source, scope: sourceType);

    onRemove() => sourceType == SourceType.excluded
        ? manager.removeSourceFromExcludedList(source)
        : manager.removeSourceFromTrustedList(source);
    onAdd() => manager.removePendingSourceOperation(source);

    return SourceListItem(
        source: source,
        isPendingAddition: isPendingAddition,
        isPendingRemoval: isPendingRemoval,
        onActionTapped: isPendingRemoval ? onAdd : onRemove);
  }
}
