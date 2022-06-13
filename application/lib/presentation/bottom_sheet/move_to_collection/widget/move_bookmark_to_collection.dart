import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_image.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/select_item_list.dart';
import 'package:xayn_discovery_app/presentation/collection_card/util/collection_card_managers_cache.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';

class MoveBookmarkToCollectionBottomSheet extends BottomSheetBase {
  MoveBookmarkToCollectionBottomSheet({
    Key? key,
    required String bookmarkUrl,
    UniqueId? initialSelectedCollection,
    VoidCallback? onSystemPop,
    required VoidCallback onAddCollectionPressed,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _MoveBookmarkToCollection(
            bookmarkUrl: bookmarkUrl,
            initialSelectedCollection: initialSelectedCollection,
            onSystemPop: onSystemPop,
            onAddCollectionPressed: onAddCollectionPressed,
          ),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final String bookmarkUrl;
  final UniqueId? initialSelectedCollection;
  final VoidCallback? onSystemPop;
  final VoidCallback onAddCollectionPressed;

  const _MoveBookmarkToCollection({
    Key? key,
    required this.bookmarkUrl,
    this.initialSelectedCollection,
    required this.onAddCollectionPressed,
    this.onSystemPop,
  }) : super(key: key);

  @override
  _MoveBookmarkToCollectionState createState() =>
      _MoveBookmarkToCollectionState();
}

class _MoveBookmarkToCollectionState extends State<_MoveBookmarkToCollection>
    with BottomSheetBodyMixin, OverlayMixin<_MoveBookmarkToCollection> {
  late final MoveToCollectionManager _moveBookmarkToCollectionManager =
      di.get();
  late final CollectionCardManagersCache _collectionCardManagersCache =
      di.get();

  @override
  OverlayManager get overlayManager =>
      _moveBookmarkToCollectionManager.overlayManager;

  @override
  void initState() {
    _moveBookmarkToCollectionManager.updateInitialSelectedCollection(
      bookmarkUrl: widget.bookmarkUrl,
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
            getImage: (c) => buildCollectionImage(
                _collectionCardManagersCache.managerOf(c.id)),
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
              bookmarkUrl: widget.bookmarkUrl,
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
    widget.onAddCollectionPressed();
  }
}
