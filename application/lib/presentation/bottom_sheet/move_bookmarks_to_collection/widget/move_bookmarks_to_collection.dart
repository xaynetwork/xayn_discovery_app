import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
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
    VoidCallback? onSystemPop,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _MoveBookmarkToCollection(
            bookmarksIds: bookmarksIds,
            collectionIdToRemove: collectionIdToRemove,
            forceSelectCollection: forceSelectCollection,
            onSystemPop: onSystemPop,
          ),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final Collection? forceSelectCollection;
  final List<UniqueId> bookmarksIds;
  final UniqueId collectionIdToRemove;
  final VoidCallback? onSystemPop;

  const _MoveBookmarkToCollection({
    Key? key,
    required this.bookmarksIds,
    required this.collectionIdToRemove,
    this.forceSelectCollection,
    this.onSystemPop,
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
      onCancelPressed: () {
        widget.onSystemPop?.call();
        closeBottomSheet(context);
      },
      setup: BottomSheetFooterSetup.row(
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
      showBarrierColor: false,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(
        onSystemPop: widget.onSystemPop,
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
        showBarrierColor: false,
        builder: (_) => MoveBookmarksToCollectionBottomSheet(
          bookmarksIds: widget.bookmarksIds,
          forceSelectCollection: newCollection,
          collectionIdToRemove: widget.collectionIdToRemove,
          onSystemPop: widget.onSystemPop,
        ),
      );

  _onApplyPressed() async {
    widget.onSystemPop?.call();
    await _moveBookmarksToCollectionManager.onApplyPressed(
      bookmarksIds: widget.bookmarksIds,
      collectionIdToRemove: widget.collectionIdToRemove,
    );
    closeBottomSheet(context);
  }
}
