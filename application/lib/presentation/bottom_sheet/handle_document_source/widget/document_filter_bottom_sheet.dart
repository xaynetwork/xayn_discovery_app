import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/handle_document_source/manager/document_filter_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/handle_document_source/manager/document_filter_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/tooltip_utils.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

typedef OnMoveDocumentToCollectionError = void Function(TooltipKey);

class DocumentFilterBottomSheet extends BottomSheetBase {
  DocumentFilterBottomSheet({
    Key? key,
    required Document document,
    UniqueId? initialSelectedCollectionId,
  }) : super(
          key: key,
          body: _DocumentFilterList(
            document: document,
          ),
        );
}

class _DocumentFilterList extends StatefulWidget {
  final Document document;

  const _MoveDocumentToCollection({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  _MoveDocumentToCollectionState createState() =>
      _MoveDocumentToCollectionState();
}

class _MoveDocumentToCollectionState extends State<_DocumentFilterList>
    with BottomSheetBodyMixin {
  late final DocumentFilterManager _manager = di.get(param1: widget.document);

  @override
  Widget build(BuildContext context) {
    final body =
        BlocBuilder<DocumentFilterManager, DocumentFilterState>(
            bloc: _manager,
            builder: (_, state) {
              // if (state.shouldClose) {
              //   closeBottomSheet(context);
              // }

              if (state.filters.isNotEmpty) {
                return CollectionsListBottomSheet(
                  collections: state.collections,
                  onSelectCollection: _moveDocumentToCollectionManager!
                      .updateSelectedCollection,
                  initialSelectedCollectionId: state.selectedCollectionId,
                );
              }

              return const SizedBox.shrink();
            },
          );

    final header = BottomSheetHeader(
      headerText: R.strings.sourceHandlingTooltipLabel,
    );

    final footer = BottomSheetFooter(
      onCancelPressed: () => closeBottomSheet(context),
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: () =>
              _manager.onApplyPressed(),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Flexible(child: body),
        footer,
      ],
    );
  }

  void _showAddCollectionBottomSheet() {
    closeBottomSheet(context);
    showAppBottomSheet(
      context,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(
        onApplyPressed: (collection) => _onAddCollectionSheetClosed(
          buildContext,
          collection.id,
        ),
      ),
    );
  }

  void _onAddCollectionSheetClosed(
          BuildContext context, UniqueId newCollectionId) =>
      showAppBottomSheet(
        context,
        builder: (_) => DocumentFilterBottomSheet(
          document: widget.document,
          provider: widget.provider,
          initialSelectedCollectionId: newCollectionId,
          onError: widget.onError,
        ),
      );
}
