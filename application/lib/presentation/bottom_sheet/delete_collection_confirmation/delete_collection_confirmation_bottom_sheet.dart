import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/manager/delete_collection_confirmation_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_mixin.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player_child_builder_mixin.dart';

import 'manager/delete_collection_confirmation_manager.dart';

typedef OnApplyPressed = Function(Collection)?;
typedef OnMoveBookmarksPressed = Function(List<String> bookmarkUrls);

class DeleteCollectionConfirmationBottomSheet extends BottomSheetBase {
  DeleteCollectionConfirmationBottomSheet({
    Key? key,
    required UniqueId collectionId,
    OnApplyPressed onApplyPressed,
    VoidCallback? onSystemPop,
    required OnMoveBookmarksPressed onMovePressed,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _DeleteCollection(
            onApplyPressed: onApplyPressed,
            collectionId: collectionId,
            onSystemPop: onSystemPop,
            onMovePressed: onMovePressed,
          ),
        );
}

class _DeleteCollection extends StatefulWidget {
  const _DeleteCollection({
    Key? key,
    required this.collectionId,
    this.onApplyPressed,
    this.onSystemPop,
    required this.onMovePressed,
  }) : super(key: key);

  final OnApplyPressed onApplyPressed;
  final UniqueId collectionId;
  final VoidCallback? onSystemPop;
  final OnMoveBookmarksPressed onMovePressed;

  @override
  _CreateCollectionState createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<_DeleteCollection>
    with
        BottomSheetBodyMixin,
        AnimationPlayerChildBuilderStateMixin<_DeleteCollection>,
        OverlayMixin<_DeleteCollection> {
  late final DeleteCollectionConfirmationManager
      _deleteCollectionConfirmationManager = di.get()
        ..enteringScreen(widget.collectionId);

  @override
  OverlayManager get overlayManager =>
      _deleteCollectionConfirmationManager.overlayManager;

  @override
  final String illustrationAssetName =
      R.assets.lottie.contextual.deleteCollection;

  @override
  Widget buildChild(BuildContext context) => BlocBuilder<
          DeleteCollectionConfirmationManager,
          DeleteCollectionConfirmationState>(
        bloc: _deleteCollectionConfirmationManager,
        builder: (_, state) {
          final header = Padding(
            padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
            child: BottomSheetHeader(
              headerText: R.strings.bottomSheetDeleteCollectionHeader,
            ),
          );

          final body = state.bookmarksUrls.isNotEmpty
              ? Text(R.strings.bottomSheetDeleteCollectionWithBookmarksBody)
              : Text(
                  R.strings.bottomSheetDeleteCollectionWithNoItemsBody,
                );

          final footer = BottomSheetFooter(
            onCancelPressed: () {
              _deleteCollectionConfirmationManager.onCancelPressed();
              closeBottomSheet(context);
              widget.onSystemPop?.call();
            },
            setup: state.bookmarksUrls.isNotEmpty
                ? _buildFooterSetupForCollectionWithItems(state.bookmarksUrls)
                : _buildFooterSetupForCollectionWithNoItems(),
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              body,
              footer,
            ],
          );
        },
      );

  BottomSheetFooterSetup _buildFooterSetupForCollectionWithItems(
          List<String> bookmarkUrls) =>
      BottomSheetFooterSetup.column(
        buttonsData: [
          BottomSheetFooterButton(
            text: R.strings.bottomSheetMoveBookmarks,
            onPressed: () {
              closeBottomSheet(context);
              widget.onMovePressed(bookmarkUrls);
            },
          ),
          BottomSheetFooterButton(
            text: R.strings.bottomSheetDeleteAll,
            onPressed: () => _onDeleteAllPressed(),
          ),
        ],
      );

  BottomSheetFooterSetup _buildFooterSetupForCollectionWithNoItems() =>
      BottomSheetFooterSetup.row(
        buttonData: BottomSheetFooterButton(
          text: R.strings.bottomSheetDelete,
          onPressed: () => _onDeleteCollectionPressed(),
        ),
      );

  void _onDeleteAllPressed() {
    widget.onSystemPop?.call();
    _deleteCollectionConfirmationManager.deleteAll();
    closeBottomSheet(context);
  }

  void _onDeleteCollectionPressed() {
    widget.onSystemPop?.call();
    _deleteCollectionConfirmationManager.deleteCollection();
    closeBottomSheet(context);
  }
}
