import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/widget/create_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/manager/move_document_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/manager/move_document_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

class MoveDocumentToCollectionBottomSheet extends BottomSheetBase {
  MoveDocumentToCollectionBottomSheet({
    Key? key,
    required Document document,
    Collection? forceSelectCollection,
  }) : super(
          key: key,
          body: _MoveDocumentToCollection(
            document: document,
            forceSelectCollection: forceSelectCollection,
          ),
        );
}

class _MoveDocumentToCollection extends StatefulWidget {
  final Document document;
  final Collection? forceSelectCollection;

  const _MoveDocumentToCollection({
    Key? key,
    required this.document,
    this.forceSelectCollection,
  }) : super(key: key);

  @override
  _MoveDocumentToCollectionState createState() =>
      _MoveDocumentToCollectionState();
}

class _MoveDocumentToCollectionState extends State<_MoveDocumentToCollection>
    with BottomSheetBodyMixin {
  MoveDocumentToCollectionManager? _moveDocumentToCollectionManager;

  @override
  void initState() {
    di.getAsync<MoveDocumentToCollectionManager>().then(
      (it) async {
        await it.updateInitialSelectedCollection(
          bookmarkId: widget.document.documentUniqueId,
          forceSelectCollection: widget.forceSelectCollection,
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
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<MoveDocumentToCollectionManager,
            MoveDocumentToCollectionState>(
            bloc: _moveDocumentToCollectionManager,
            builder: (_, state) => state.collections.isNotEmpty
                ? CollectionsListBottomSheet(
                    collections: state.collections,
                    onSelectCollection: _moveDocumentToCollectionManager!
                        .updateSelectedCollection,
                    initialSelectedCollection: state.selectedCollection,
                  )
                : Container(),
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
      onCancelPressed: () => closeBottomSheet(context),
      onApplyPressed: _onApplyPressed,
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

  _showAddCollectionBottomSheet() {
    closeBottomSheet(context);
    showAppBottomSheet(
      context,
      builder: (buildContext) => CreateCollectionBottomSheet(
        onApplyPressed: (collection) => _onAddCollectionSheetClosed(
          buildContext,
          collection,
        ),
      ),
    );
  }

  _onAddCollectionSheetClosed(BuildContext context, Collection newCollection) =>
      showAppBottomSheet(
        context,
        builder: (_) => MoveDocumentToCollectionBottomSheet(
          document: widget.document,
          forceSelectCollection: newCollection,
        ),
      );

  _onApplyPressed() {
    closeBottomSheet(context);
    _moveDocumentToCollectionManager!.onApplyPressed(
      document: widget.document,
    );
  }
}
