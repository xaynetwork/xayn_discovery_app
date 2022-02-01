import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/manager/create_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/manager/create_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnApplyPressed = Function(Collection)?;

class CreateOrRenameCollectionBottomSheet extends BottomSheetBase {
  CreateOrRenameCollectionBottomSheet({
    Key? key,
    UniqueId? collectionId,
    _OnApplyPressed onApplyPressed,
  }) : super(
          key: key,
          body: _CreateOrRenameCollection(
            onApplyPressed: onApplyPressed,
            collectionId: collectionId,
          ),
        );
}

class _CreateOrRenameCollection extends StatefulWidget {
  const _CreateOrRenameCollection({
    Key? key,
    this.collectionId,
    this.onApplyPressed,
  }) : super(key: key);

  final _OnApplyPressed onApplyPressed;
  final UniqueId? collectionId;

  @override
  _CreateOrRenameCollectionState createState() =>
      _CreateOrRenameCollectionState();
}

class _CreateOrRenameCollectionState extends State<_CreateOrRenameCollection>
    with BottomSheetBodyMixin {
  late final CreateOrRenameCollectionManager _createOrRenameCollectionManager =
      di.get();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CreateOrRenameCollectionManager, CreateCollectionState>(
        bloc: _createOrRenameCollectionManager,
        listenWhen: (_, current) => current.newCollection != null,
        listener: (context, state) => _closeSheet(state.newCollection!),
        builder: (context, state) {
          final textField = AppTextField(
            hintText: R.strings.bottomSheetCreateCollectionTextFieldHint,
            onChanged: _createOrRenameCollectionManager.updateCollectionName,
            errorText: state.errorMessage,
          );

          final header = Padding(
            padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
            child: BottomSheetHeader(
              headerText: widget.collectionId == null
                  ? R.strings.bottomSheetCreateCollectionHeader
                  : 'Rename collection',
            ),
          );

          final footer = BottomSheetFooter(
            onCancelPressed: () => closeBottomSheet(context),
            setup: BottomSheetFooterSetup.withOneRaisedButton(
              buttonData: BottomSheetFooterButton(
                text: widget.collectionId == null
                    ? R.strings.bottomSheetCreate
                    : 'Rename',
                onPressed: _onApplyPressed,
                isDisabled: state.collectionName.trim().isEmpty,
              ),
            ),
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
        },
      );

  void _onApplyPressed() {
    if (widget.collectionId == null) {
      _createOrRenameCollectionManager.createCollection();
    } else {
      // _createOrRenameCollectionManager.renameCollection(widget.collectionId!);
    }
  }

  void _closeSheet(Collection newCollection) {
    closeBottomSheet(context);
    if (widget.onApplyPressed != null) widget.onApplyPressed!(newCollection);
  }
}
