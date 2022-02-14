import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/manager/create_or_rename_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/manager/create_or_rename_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnApplyPressed = Function(Collection)?;

/// Used for creating a new collection or renaming an existing one
/// When [collection] is:
/// 1) [null]: a new collection is being created
/// 2) [not null]: an existing collection is being renamed
class CreateOrRenameCollectionBottomSheet extends BottomSheetBase {
  CreateOrRenameCollectionBottomSheet({
    Key? key,
    Collection? collection,
    _OnApplyPressed onApplyPressed,
  }) : super(
          key: key,
          body: _CreateOrRenameCollection(
            onApplyPressed: onApplyPressed,
            collection: collection,
          ),
        );
}

class _CreateOrRenameCollection extends StatefulWidget {
  const _CreateOrRenameCollection({
    Key? key,
    this.collection,
    this.onApplyPressed,
  }) : super(key: key);

  final _OnApplyPressed onApplyPressed;
  final Collection? collection;

  @override
  _CreateOrRenameCollectionState createState() =>
      _CreateOrRenameCollectionState();
}

class _CreateOrRenameCollectionState extends State<_CreateOrRenameCollection>
    with BottomSheetBodyMixin {
  late final CreateOrRenameCollectionManager _createOrRenameCollectionManager =
      di.get();
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _maybeSetInitialCollectionName();
    super.initState();
  }

  /// If widget.collection is not null it means that an existing
  /// collection is being renamed. In this case:
  /// 1) Update the collection name in the state through the manager
  /// 2) Show in the input field the name of the collection being renamed
  void _maybeSetInitialCollectionName() {
    final collectionName = widget.collection?.name;
    if (collectionName == null) return;
    _createOrRenameCollectionManager.updateCollectionName(collectionName);
    _textEditingController.text = collectionName;
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<
          CreateOrRenameCollectionManager, CreateOrRenameCollectionState>(
        bloc: _createOrRenameCollectionManager,
        listenWhen: (_, current) => current.newCollection != null,
        listener: (context, state) => _closeSheet(state.newCollection!),
        builder: (context, state) {
          final textField = AppTextField(
            autofocus: true,
            controller: _textEditingController,
            hintText: R.strings.bottomSheetCreateCollectionTextFieldHint,
            onChanged: _createOrRenameCollectionManager.updateCollectionName,
            errorText: state.errorMessage,
          );

          final header = Padding(
            padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
            child: BottomSheetHeader(
              headerText: widget.collection == null
                  ? R.strings.bottomSheetCreateCollectionHeader
                  : R.strings.bottomSheetRenameCollectionHeader,
            ),
          );

          final footer = BottomSheetFooter(
            onCancelPressed: () => closeBottomSheet(context),
            setup: BottomSheetFooterSetup.row(
              buttonData: BottomSheetFooterButton(
                text: widget.collection == null
                    ? R.strings.bottomSheetCreate
                    : R.strings.bottomSheetRename,
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
    final collectionId = widget.collection?.id;
    if (collectionId != null) {
      _createOrRenameCollectionManager.renameCollection(collectionId);
    } else {
      _createOrRenameCollectionManager.createCollection();
    }
  }

  void _closeSheet(Collection newCollection) {
    closeBottomSheet(context);
    widget.onApplyPressed?.call(newCollection);
  }
}
