import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/add_collection/manager/create_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/widget/move_bookmark_to_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/widget/bottom_sheet.dart';

class AddCollectionBottomSheet extends BottomSheetBase {
  AddCollectionBottomSheet({
    Key? key,
    UniqueId? bookmarkIdToMoveAfterAddingCollection,
  }) : super(
          key: key,
          body: _AddCollection(
            bookmarkIdToMoveAfterAddingCollection:
                bookmarkIdToMoveAfterAddingCollection,
          ),
        );
}

class _AddCollection extends StatefulWidget {
  const _AddCollection({Key? key, this.bookmarkIdToMoveAfterAddingCollection})
      : super(key: key);

  final UniqueId? bookmarkIdToMoveAfterAddingCollection;

  @override
  _AddCollectionState createState() => _AddCollectionState();
}

class _AddCollectionState extends State<_AddCollection>
    with BottomSheetBodyMixin {
  late final CreateCollectionManager _createCollectionManager = di.get();
  String? collectionName;

  @override
  Widget build(BuildContext context) {
    final textField = AppTextField(
      hintText: 'Collection name',
      onChanged: updateCollectionName,
    );

    const header = BottomSheetHeader(
      headerText: 'Create a new Collection',
    );

    final footer = BottomSheetFooter(
      onCancelPressed: () => closeBottomSheet(context),
      onApplyPressed: onApplyPressed,
      isApplyDisabled: collectionName == null || collectionName!.isEmpty,
      applyBtnText: 'Create',
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        textField,
        footer,
      ],
    );
  }

  void updateCollectionName(String name) => setState(
        () => collectionName = name,
      );

  void onApplyPressed() async {
    final newCollection =
        await _createCollectionManager.createCollection(collectionName!);
    closeBottomSheet(context);
    if (widget.bookmarkIdToMoveAfterAddingCollection == null) return;
    showAppBottomSheet(
      context,
      builder: (_) => MoveBookmarkToCollectionBottomSheet(
        bookmarkId: widget.bookmarkIdToMoveAfterAddingCollection!,
        forceSelectCollection: newCollection,
      ),
    );
  }
}
