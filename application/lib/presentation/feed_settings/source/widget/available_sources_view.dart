import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/source/widget/source_list_item.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

typedef OnSourceTapped = void Function(Source);

class AvailableSourcesView extends StatelessWidget {
  final SourcesManager manager;
  final Set<AvailableSource> sources;
  final SourceType sourceType;
  final OnSourceTapped onTap;

  const AvailableSourcesView.excludedSources({
    Key? key,
    required this.manager,
    required this.sources,
    required this.onTap,
  })  : sourceType = SourceType.excluded,
        super(key: key);

  const AvailableSourcesView.trustedSources({
    Key? key,
    required this.manager,
    required this.sources,
    required this.onTap,
  })  : sourceType = SourceType.trusted,
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

  Widget _createItem(BuildContext context, AvailableSource availableSource) {
    final source = Source(availableSource.domain);

    return SourceListItem(
      source: source,
      isPendingAddition: false,
      isPendingRemoval: false,
      fixedIcon: R.assets.icons.plus,
      onActionTapped: () => onTap(source),
    );
  }
}
