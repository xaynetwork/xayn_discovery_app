import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmarks_to_collection/manager/move_bookmarks_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmarks_to_collection/manager/move_bookmarks_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_image.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/select_item_list.dart';
import 'package:xayn_discovery_app/presentation/collection_card/util/collection_card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/mixin/screen_duration_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_mixin.dart';

class MoveBookmarksToCollectionBottomSheet extends BottomSheetBase {
  MoveBookmarksToCollectionBottomSheet({
    Key? key,
    required List<UniqueId> bookmarksIds,
    required UniqueId collectionIdToRemove,
    UniqueId? initialSelectedCollection,
    VoidCallback? onSystemPop,
    required VoidCallback onAddCollectionPressed,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _MoveBookmarkToCollection(
            bookmarksIds: bookmarksIds,
            collectionIdToRemove: collectionIdToRemove,
            initialSelectedCollection: initialSelectedCollection,
            onSystemPop: onSystemPop,
            onAddCollectionPressed: onAddCollectionPressed,
          ),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final List<UniqueId> bookmarksIds;
  final UniqueId collectionIdToRemove;
  final UniqueId? initialSelectedCollection;
  final VoidCallback? onSystemPop;
  final VoidCallback onAddCollectionPressed;

  const _MoveBookmarkToCollection({
    Key? key,
    required this.bookmarksIds,
    required this.collectionIdToRemove,
    this.initialSelectedCollection,
    this.onSystemPop,
    required this.onAddCollectionPressed,
  }) : super(key: key);

  @override
  _MoveBookmarkToCollectionState createState() =>
      _MoveBookmarkToCollectionState();
}

class _MoveBookmarkToCollectionState extends State<_MoveBookmarkToCollection>
    with
        BottomSheetBodyMixin,
        ScreenDurationMixin,
        OverlayMixin<_MoveBookmarkToCollection> {
  late final MoveBookmarksToCollectionManager
      _moveBookmarksToCollectionManager = di.get();
  late final CollectionCardManagersCache _collectionCardManagersCache =
      di.get();

  @override
  OverlayManager get overlayManager =>
      _moveBookmarksToCollectionManager.overlayManager;

  @override
  void initState() {
    _moveBookmarksToCollectionManager.enteringScreen(
      collectionIdToRemove: widget.collectionIdToRemove,
      selectedCollectionId: widget.initialSelectedCollection,
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
          ? _buildCollectionsList(state)
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

  _buildCollectionsList(MoveBookmarksToCollectionState state) {
    final selectedCollection = state.collections
        .firstWhereOrNull((c) => c.id == state.selectedCollectionId);
    return SelectItemList<Collection>(
      items: state.collections,
      onSelectItem: (c) =>
          _moveBookmarksToCollectionManager.updateSelectedCollection(c.id),
      getTitle: (c) => c.name,
      getImage: (c) =>
          buildCollectionImage(_collectionCardManagersCache.managerOf(c.id)),
      preSelectedItems: selectedCollection == null ? {} : {selectedCollection},
    );
  }

  _showAddCollectionBottomSheet() {
    closeBottomSheet(context);
    widget.onAddCollectionPressed();
  }

  _onApplyPressed() async {
    widget.onSystemPop?.call();
    await _moveBookmarksToCollectionManager.onApplyPressed(
      bookmarksIds: widget.bookmarksIds,
      collectionIdToRemove: widget.collectionIdToRemove,
    );
    if (mounted) closeBottomSheet(context);
  }
}
