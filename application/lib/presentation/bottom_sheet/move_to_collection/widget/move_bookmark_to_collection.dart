import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_image.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/select_item_list.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_card_managers_mixin.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';

class MoveBookmarkToCollectionBottomSheet extends BottomSheetBase {
  MoveBookmarkToCollectionBottomSheet({
    Key? key,
    required UniqueId bookmarkId,
    UniqueId? initialSelectedCollection,
    VoidCallback? onSystemPop,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _MoveBookmarkToCollection(
            bookmarkId: bookmarkId,
            initialSelectedCollection: initialSelectedCollection,
            onSystemPop: onSystemPop,
          ),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final UniqueId bookmarkId;
  final UniqueId? initialSelectedCollection;
  final VoidCallback? onSystemPop;

  const _MoveBookmarkToCollection({
    Key? key,
    required this.bookmarkId,
    this.initialSelectedCollection,
    this.onSystemPop,
  }) : super(key: key);

  @override
  _MoveBookmarkToCollectionState createState() =>
      _MoveBookmarkToCollectionState();
}

class _MoveBookmarkToCollectionState extends State<_MoveBookmarkToCollection>
    with
        BottomSheetBodyMixin,
        CollectionCardManagersMixin,
        OverlayMixin<_MoveBookmarkToCollection> {
  late final MoveToCollectionManager _moveBookmarkToCollectionManager =
      di.get();

  @override
  OverlayManager get overlayManager =>
      _moveBookmarkToCollectionManager.overlayManager;

  @override
  void initState() {
    _moveBookmarkToCollectionManager.updateInitialSelectedCollection(
      bookmarkId: widget.bookmarkId,
      initialSelectedCollectionId: widget.initialSelectedCollection,
    );
    super.initState();
  }

  @override
  void dispose() {
    _moveBookmarkToCollectionManager.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocBuilder<MoveToCollectionManager, MoveToCollectionState>(
      bloc: _moveBookmarkToCollectionManager,
      builder: (_, state) {
        if (state.shouldClose) {
          closeBottomSheet(context);
          widget.onSystemPop?.call();
        }

        if (state.collections.isNotEmpty) {
          final selectedCollection = state.collections
              .firstWhereOrNull((c) => c.id == state.selectedCollectionId);
          return SelectItemList<Collection>(
            items: state.collections,
            onSelectItem: (c) =>
                _moveBookmarkToCollectionManager.updateSelectedCollection(c.id),
            getTitle: (c) => c.name,
            getImage: (c) => buildCollectionImage(managerOf(c.id)),
            preSelectedItems:
                selectedCollection == null ? {} : {selectedCollection},
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
        _moveBookmarkToCollectionManager.onCancelPressed();
        closeBottomSheet(context);
        widget.onSystemPop?.call();
      },
      setup: BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetApply,
          onPressed: () {
            _moveBookmarkToCollectionManager.onApplyToBookmarkPressed(
              bookmarkId: widget.bookmarkId,
            );
          },
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
      showBarrierColor: widget.onSystemPop == null,
      builder: (buildContext) => CreateOrRenameCollectionBottomSheet(
        onApplyPressed: (collection) => _onAddCollectionSheetClosed(
          buildContext,
          collection.id,
        ),
        onSystemPop: widget.onSystemPop,
      ),
    );
  }

  _onAddCollectionSheetClosed(BuildContext context, UniqueId newCollectionId) =>
      showAppBottomSheet(
        context,
        showBarrierColor: widget.onSystemPop == null,
        builder: (_) => MoveBookmarkToCollectionBottomSheet(
          bookmarkId: widget.bookmarkId,
          initialSelectedCollection: newCollectionId,
          onSystemPop: widget.onSystemPop,
        ),
      );
}
