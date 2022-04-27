import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/manager/document_filter_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/manager/document_filter_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/select_item_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
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

  const _DocumentFilterList({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  _DocumentFilterListState createState() => _DocumentFilterListState();
}

class _DocumentFilterListState extends State<_DocumentFilterList>
    with BottomSheetBodyMixin {
  late final DocumentFilterManager _manager = di.get(param1: widget.document);

  @override
  Widget build(BuildContext context) {
    Widget body(DocumentFilterState state) {
      var filters = state.filters;
      if (filters.isNotEmpty) {
        return SelectItemList<DocumentFilter>(
          items: filters.keys.toList(),
          preSelectedItems:
              filters.entries.where((e) => e.value).map((e) => e.key).toSet(),
          onSelectItem: _manager.onFilterTogglePressed,
          getTitle: (e) => e.fold((host) => host, (topic) => topic),
          getImage: (e) => e.fold(
              (host) => buildThumbnailFromFaviconHost(host),
              (topic) => Thumbnail.assetImage(
                  R.assets.graphics.formsEmptyCollection,
                  backgroundColor: R.colors.collectionsScreenCard)),
        );
      }

      return const SizedBox.shrink();
    }

    final header = BottomSheetHeader(
      headerText: R.strings.sourceHandlingTooltipLabel,
    );

    Widget footer(DocumentFilterState state) => BottomSheetFooter(
          onCancelPressed: () => closeBottomSheet(context),
          setup: BottomSheetFooterSetup.row(
            buttonData: BottomSheetFooterButton(
              isDisabled: !state.hasPendingChanges,
              text: R.strings.bottomSheetApply,
              onPressed: () {
                _manager.onApplyChangesPressed();
                closeBottomSheet(context);
              },
            ),
          ),
        );

    return BlocBuilder<DocumentFilterManager, DocumentFilterState>(
        bloc: _manager,
        builder: (_, state) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Flexible(child: body(state)),
                footer(state),
              ],
            ));
  }
}
