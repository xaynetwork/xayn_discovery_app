import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmarks_to_collection/manager/move_bookmarks_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmarks_to_collection/manager/move_bookmarks_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class MoveBookmarksToCollectionBottomSheet extends BottomSheetBase {
  MoveBookmarksToCollectionBottomSheet({
    Key? key,
    required List<UniqueId> bookmarksIds,
    required UniqueId collectionIdToRemove,
    Collection? forceSelectCollection,
  }) : super(
          key: key,
          body: _MoveBookmarkToCollection(
            bookmarksIds: bookmarksIds,
            collectionIdToRemove: collectionIdToRemove,
            forceSelectCollection: forceSelectCollection,
          ),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final Collection? forceSelectCollection;
  final List<UniqueId> bookmarksIds;
  final UniqueId collectionIdToRemove;

  const _MoveBookmarkToCollection({
    Key? key,
    required this.bookmarksIds,
    required this.collectionIdToRemove,
    this.forceSelectCollection,
  }) : super(key: key);

  @override
  _MoveBookmarkToCollectionState createState() =>
      _MoveBookmarkToCollectionState();
}

class _MoveBookmarkToCollectionState extends State<_MoveBookmarkToCollection>
    with BottomSheetBodyMixin {
  final MoveBookmarksToCollectionManager _moveBookmarksToCollectionManager =
      di.get();

  @override
  void initState() {
    _moveBookmarksToCollectionManager.enteringScreen(
      collectionIdToRemove: widget.collectionIdToRemove,
      selectedCollection: widget.forceSelectCollection,
    );
    super.initState();
  }

  @override
  void dispose() {
    _moveBookmarksToCollectionManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocBuilder<MoveBookmarksToCollectionManager,
        MoveBookmarksToCollectionState>(
      bloc: _moveBookmarksToCollectionManager,
      builder: (_, state) => state.collections.isNotEmpty
          ? CollectionsListBottomSheet(
              collections: state.collections,
              onSelectCollection:
                  _moveBookmarksToCollectionManager.updateSelectedCollection,
              initialSelectedCollection: state.selectedCollection,
            )
          : const SizedBox.shrink(),
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
      setup: BottomSheetFooterSetup.withOneRaisedButton(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: _onApplyPressed,
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

  _showAddCollectionBottomSheet() {
    closeBottomSheet(context);
    showAppBottomSheet(
      context,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(
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
        builder: (_) => MoveBookmarksToCollectionBottomSheet(
          bookmarksIds: widget.bookmarksIds,
          forceSelectCollection: newCollection,
          collectionIdToRemove: widget.collectionIdToRemove,
        ),
      );

  _onApplyPressed() async {
    await _moveBookmarksToCollectionManager.onApplyPressed(
      bookmarksIds: widget.bookmarksIds,
      collectionIdToRemove: widget.collectionIdToRemove,
    );
    closeBottomSheet(context);
  }
}
