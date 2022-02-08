import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/manager/create_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/manager/create_collection_state.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnApplyPressed = Function(Collection)?;

class CreateCollectionBottomSheet extends BottomSheetBase {
  CreateCollectionBottomSheet({
    Key? key,
    _OnApplyPressed onApplyPressed,
  }) : super(
          key: key,
          body: _CreateCollection(
            onApplyPressed: onApplyPressed,
          ),
        );
}

class _CreateCollection extends StatefulWidget {
  const _CreateCollection({
    Key? key,
    this.onApplyPressed,
  }) : super(key: key);

  final _OnApplyPressed onApplyPressed;

  @override
  _CreateCollectionState createState() => _CreateCollectionState();
}

class _CreateCollectionState extends State<_CreateCollection>
    with BottomSheetBodyMixin {
  late final CreateCollectionManager _createCollectionManager = di.get();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<CreateCollectionManager, CreateCollectionState>(
        bloc: _createCollectionManager,
        listenWhen: (_, current) => current.newCollection != null,
        listener: (context, state) => _closeSheet(state.newCollection!),
        builder: (context, state) {
          final textField = AppTextField(
            hintText: R.strings.bottomSheetCreateCollectionTextFieldHint,
            onChanged: _createCollectionManager.updateCollectionName,
            errorText: state.errorMessage,
          );

          final header = Padding(
            padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
            child: BottomSheetHeader(
              headerText: R.strings.bottomSheetCreateCollectionHeader,
            ),
          );

          final footer = BottomSheetFooter(
            onCancelPressed: () => closeBottomSheet(context),
            onApplyPressed: _createCollectionManager.createCollection,
            isApplyDisabled: state.collectionName.trim().isEmpty,
            applyBtnText: R.strings.bottomSheetCreate,
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

  void _closeSheet(Collection newCollection) {
    closeBottomSheet(context);
    if (widget.onApplyPressed != null) widget.onApplyPressed!(newCollection);
  }
}
