import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/add_collection/widget/add_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/bottom_sheet.dart';

class MoveBookmarkToCollectionBottomSheet extends BottomSheetBase {
  MoveBookmarkToCollectionBottomSheet({
    Key? key,
    required UniqueId bookmarkId,
    Collection? forceSelectCollection,
  }) : super(
          key: key,
          body: _MoveBookmarkToCollection(
            bookmarkId: bookmarkId,
            forceSelectCollection: forceSelectCollection,
          ),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final UniqueId bookmarkId;
  final Collection? forceSelectCollection;

  const _MoveBookmarkToCollection({
    Key? key,
    required this.bookmarkId,
    this.forceSelectCollection,
  }) : super(key: key);

  @override
  _MoveBookmarkToCollectionState createState() =>
      _MoveBookmarkToCollectionState();
}

class _MoveBookmarkToCollectionState extends State<_MoveBookmarkToCollection>
    with BottomSheetBodyMixin {
  MoveBookmarkToCollectionManager? _moveBookmarkToCollectionManager;

  @override
  void initState() {
    di.getAsync<MoveBookmarkToCollectionManager>().then(
      (it) async {
        await it.updateInitialSelectedCollection(
          bookmarkId: widget.bookmarkId,
          forceSelectCollection: widget.forceSelectCollection,
        );
        setState(
          () => _moveBookmarkToCollectionManager = it,
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _moveBookmarkToCollectionManager?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = _moveBookmarkToCollectionManager == null
        ? const Center(child: CircularProgressIndicator())
        : BlocBuilder<MoveBookmarkToCollectionManager,
            MoveBookmarkToCollectionState>(
            bloc: _moveBookmarkToCollectionManager,
            builder: (_, state) => state.collections.isNotEmpty
                ? CollectionsListBottomSheet(
                    collections: state.collections,
                    onSelectCollection: _moveBookmarkToCollectionManager!
                        .updateSelectedCollection,
                    initialSelectedCollection: state.selectedCollection,
                  )
                : Container(),
          );

    final scrollableBody = Flexible(
      child: SingleChildScrollView(
        controller: getScrollController(context),
        child: body,
      ),
    );

    final plusIcon = SvgPicture.asset(
      R.assets.icons.plus,
      fit: BoxFit.none,
      color: R.colors.icon,
      height: R.dimen.smallIconSize,
      width: R.dimen.smallIconSize,
    );

    final iconButton = GestureDetector(
      onTap: _showAddCollectionBottomSheet,
      child: plusIcon,
    );

    final header = BottomSheetHeader(
      headerText: 'Save to',
      actionWidget: iconButton,
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
        scrollableBody,
        footer,
      ],
    );
  }

  _showAddCollectionBottomSheet() {
    closeBottomSheet(context);
    showAppBottomSheet(
      context,
      builder: (_) => AddCollectionBottomSheet(
        bookmarkIdToMoveAfterAddingCollection: widget.bookmarkId,
      ),
    );
  }

  _onApplyPressed() {
    closeBottomSheet(context);
    _moveBookmarkToCollectionManager!.onApplyPressed(
      bookmarkId: widget.bookmarkId,
    );
  }
}
