import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/tooltip_utils.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class MoveDocumentToCollectionBottomSheet extends BottomSheetBase {
  MoveDocumentToCollectionBottomSheet({
    Key? key,
    required Document document,
    required OnToolTipError onError,
    required DocumentProvider? provider,
    UniqueId? initialSelectedCollectionId,
  }) : super(
          key: key,
          body: _MoveDocumentToCollection(
            document: document,
            provider: provider,
            initialSelectedCollectionId: initialSelectedCollectionId,
            onError: onError,
          ),
        );
}

class _MoveDocumentToCollection extends StatefulWidget {
  final Document document;
  final DocumentProvider? provider;
  final UniqueId? initialSelectedCollectionId;
  final OnToolTipError onError;

  const _MoveDocumentToCollection({
    Key? key,
    required this.document,
    required this.onError,
    required this.provider,
    this.initialSelectedCollectionId,
  }) : super(key: key);

  @override
  _MoveDocumentToCollectionState createState() =>
      _MoveDocumentToCollectionState();
}

class _MoveDocumentToCollectionState extends State<_MoveDocumentToCollection>
    with BottomSheetBodyMixin {
  MoveToCollectionManager? _moveDocumentToCollectionManager;

  @override
  void initState() {
    di.getAsync<MoveToCollectionManager>().then(
      (it) async {
        await it.updateInitialSelectedCollection(
          bookmarkId: widget.document.documentUniqueId,
          initialSelectedCollectionId: widget.initialSelectedCollectionId,
        );
        setState(
          () => _moveDocumentToCollectionManager = it,
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _moveDocumentToCollectionManager?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = _moveDocumentToCollectionManager == null
        ? const SizedBox.shrink()
        : BlocConsumer<MoveToCollectionManager, MoveToCollectionState>(
            bloc: _moveDocumentToCollectionManager,
            listener: (_, state) {
              if (state.hasError) {
                TooltipKey? key = TooltipUtils.getErrorKey(state.errorObj);
                if (key != null) widget.onError(key);
              }
            },
            builder: (_, state) {
              if (state.shouldClose) {
                closeBottomSheet(context);
              }

              if (state.collections.isNotEmpty) {
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
      headerText: R.strings.bottomSheetSaveTo,
      actionWidget: AppGhostButton.icon(
        R.assets.icons.plus,
        onPressed: _showAddCollectionBottomSheet,
        contentPadding: EdgeInsets.zero,
      ),
    );

    final footer = BottomSheetFooter(
      onCancelPressed: () {
        _moveDocumentToCollectionManager!.onCancelPressed();
        closeBottomSheet(context);
      },
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: () =>
              _moveDocumentToCollectionManager!.onApplyToDocumentPressed(
            document: widget.document,
            provider: widget.provider,
          ),
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
        builder: (_) => MoveDocumentToCollectionBottomSheet(
          document: widget.document,
          provider: widget.provider,
          initialSelectedCollectionId: newCollectionId,
          onError: widget.onError,
        ),
      );
}
