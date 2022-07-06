import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class DocumentFilterBottomSheet extends BottomSheetBase {
  DocumentFilterBottomSheet({
    Key? key,
    required Document document,
  }) : super(
          key: key,
          body: _DocumentFilterList(
            document: document,
          ),
        );
}

class _DocumentFilterList extends StatefulWidget {
  final Document document;
  final Source source;

  _DocumentFilterList({
    Key? key,
    required this.document,
  })  : source = Source.fromJson(document.resource.url.host),
        super(key: key);

  @override
  _DocumentFilterListState createState() => _DocumentFilterListState();
}

class _DocumentFilterListState extends State<_DocumentFilterList>
    with BottomSheetBodyMixin {
  late final SourcesManager _manager = di.get();

  @override
  Widget build(BuildContext context) {
    final body = _SourceItem(item: widget.source);
    final header = BottomSheetHeader(
      headerText: R.strings.sourceHandlingTooltipLabel,
    );
    final footer = BottomSheetFooter(
      onCancelPressed: () => closeBottomSheet(context),
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          isDisabled: false,
          text: R.strings.bottomSheetApply,
          onPressed: () {
            _manager
              ..addSourceToExcludedList(widget.source)
              ..applyChanges(isBatchedProcess: false);
            closeBottomSheet(context);
          },
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimationPlayer.asset(R.assets.lottie.contextual.sourceFilter),
        header,
        Flexible(child: body),
        footer,
      ],
    );
  }
}

class _SourceItem extends StatelessWidget {
  final Source item;

  const _SourceItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = buildThumbnailFromFaviconHost(item.value);
    final collectionName = Text(
      item.value,
      style: R.styles.mBoldStyle,
      overflow: TextOverflow.ellipsis,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        image,
        SizedBox(width: R.dimen.unit2),
        Expanded(child: collectionName),
      ],
    );
  }
}
