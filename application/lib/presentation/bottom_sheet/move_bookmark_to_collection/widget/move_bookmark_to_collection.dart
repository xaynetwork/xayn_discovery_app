import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/add_collection/widget/add_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/collections_list.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/bottom_sheet.dart';

class MoveBookmarkToCollectionBottomSheet extends BottomSheetBase {
  final UniqueId bookmarkId;

  MoveBookmarkToCollectionBottomSheet({Key? key, required this.bookmarkId})
      : super(
          key: key,
          body: _MoveBookmarkToCollection(bookmarkId: bookmarkId),
        );
}

class _MoveBookmarkToCollection extends StatefulWidget {
  final UniqueId bookmarkId;

  const _MoveBookmarkToCollection({Key? key, required this.bookmarkId})
      : super(key: key);

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
          (it) => setState(
            () => _moveBookmarkToCollectionManager = it,
          ),
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
        ? const Text('loading')
        : BlocBuilder<MoveBookmarkToCollectionManager,
                MoveBookmarkToCollectionState>(
            bloc: _moveBookmarkToCollectionManager,
            builder: (_, state) {
              if (state.collections.isNotEmpty) {
                return CollectionsListBottomSheet(
                  collections: state.collections,
                  onSelectCollection: _moveBookmarkToCollectionManager!
                      .updateSelectedCollection,
                );
              }
              return Container();
            });

    final scrollableBody = Flexible(
      child: SingleChildScrollView(
        controller: getScrollController(context),
        child: body,
      ),
    );

    final header = _Header(
      onAddCollectionPressed: _showAddCollectionBottomSheet,
    );

    final footer = _Footer(
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
    showXaynBottomSheet(
      context,
      builder: (_) => const AddCollectionBottomSheet(),
    );
  }

  _onApplyPressed() {
    closeBottomSheet(context);
    _moveBookmarkToCollectionManager!
        .moveBookmarkToSelectedCollection(bookmarkId: widget.bookmarkId);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
    required this.onAddCollectionPressed,
  }) : super(key: key);

  final VoidCallback onAddCollectionPressed;

  @override
  Widget build(BuildContext context) {
    // todo: move to strings
    const saveTo = 'Save to';

    //todo: move to xayn_design
    const style = TextStyle(fontSize: 13);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          saveTo,
          style: style,
        ),
        AppGhostButton.icon(
          R.assets.icons.plus,
          onPressed: onAddCollectionPressed,
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    Key? key,
    required this.onCancelPressed,
    required this.onApplyPressed,
  }) : super(key: key);

  final VoidCallback onCancelPressed;
  final VoidCallback onApplyPressed;

  @override
  Widget build(BuildContext context) {
    final cancelButton = AppGhostButton.text(
      'Cancel',
      onPressed: onCancelPressed,
    );
    final applyButton = AppRaisedButton.text(
      text: 'Apply',
      onPressed: onApplyPressed,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        cancelButton,
        applyButton,
      ],
    );
  }
}
