import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import 'delete_collection_confirmation_manager.dart';

typedef _OnApplyPressed = Function(Collection)?;

class DeleteCollectionConfirmationBottomSheet extends BottomSheetBase {
  DeleteCollectionConfirmationBottomSheet({
    Key? key,
    required UniqueId collectionId,
    _OnApplyPressed onApplyPressed,
  }) : super(
          key: key,
          body: _DeleteCollection(
            onApplyPressed: onApplyPressed,
            collectionId: collectionId,
          ),
        );
}

class _DeleteCollection extends StatefulWidget {
  const _DeleteCollection({
    Key? key,
    required this.collectionId,
    this.onApplyPressed,
  }) : super(key: key);

  final _OnApplyPressed onApplyPressed;
  final UniqueId collectionId;

  @override
  _CreateCollectionState createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<_DeleteCollection>
    with BottomSheetBodyMixin {
  late final DeleteCollectionConfirmationManager
      _deleteCollectionConfirmationManager = di.get();

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
      child: BottomSheetHeader(
        headerText: R.strings.bottomSheetDeleteCollectionHeader,
      ),
    );

    final body = Text(
      R.strings.bottomSheetDeleteCollectionWithBookmarksBody,
    );

    final footer = BottomSheetFooter(
      onCancelPressed: () => closeBottomSheet(context),
      setup: BottomSheetFooterSetup.withTwoRaisedButtons(
        buttonsData: [
          BottomSheetFooterButton(
            text: R.strings.bottomSheetMoveBookmarks,
            onPressed: () => _onSecondApplyPressed(widget.collectionId),
          ),
          BottomSheetFooterButton(
            text: R.strings.bottomSheetDeleteAll,
            onPressed: () => _onApplyPressed(widget.collectionId),
          ),
        ],
      ),
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
  }

  void _onApplyPressed(UniqueId collectionId) {
    _deleteCollectionConfirmationManager.removeCollection(
        collectionId: collectionId);
    _closeSheet();
  }

  void _onSecondApplyPressed(UniqueId collectionId) {
    _deleteCollectionConfirmationManager.removeCollection(
        collectionId: collectionId);
    _closeSheet();
  }

  void _closeSheet() {
    closeBottomSheet(context);
  }
}
