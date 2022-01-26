import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/add_collection/manager/create_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _OnAddCollectionSheetClosed = Function(Collection);

class AddCollectionBottomSheet extends BottomSheetBase {
  AddCollectionBottomSheet({
    Key? key,
    _OnAddCollectionSheetClosed? onSheetClosed,
  }) : super(
          key: key,
          body: _AddCollection(
            onSheetClosed: onSheetClosed,
          ),
        );
}

class _AddCollection extends StatefulWidget {
  const _AddCollection({
    Key? key,
    this.onSheetClosed,
  }) : super(key: key);

  final _OnAddCollectionSheetClosed? onSheetClosed;

  @override
  _AddCollectionState createState() => _AddCollectionState();
}

class _AddCollectionState extends State<_AddCollection>
    with BottomSheetBodyMixin {
  late final CreateCollectionManager _createCollectionManager = di.get();
  String? collectionName;

  @override
  Widget build(BuildContext context) {
    final textField = AppTextField(
      hintText: R.strings.bottomSheetCreateCollectionTextFieldHint,
      onChanged: updateCollectionName,
    );

    final header = Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
      child: BottomSheetHeader(
        headerText: R.strings.bottomSheetCreateCollectionHeader,
      ),
    );

    final footer = BottomSheetFooter(
      onCancelPressed: () => closeBottomSheet(context),
      onApplyPressed: () => onApplyPressed(collectionName),
      isApplyDisabled: collectionName == null || collectionName!.trim().isEmpty,
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
  }

  void updateCollectionName(String name) => setState(
        () => collectionName = name,
      );

  void onApplyPressed(String? collectionName) async {
    if (collectionName == null) {
      throw Exception(
          'Add Collection Bottom Sheet: Not possible to add nullable collection name.');
    }
    final newCollection =
        await _createCollectionManager.createCollection(collectionName);
    closeBottomSheet(context);
    if (widget.onSheetClosed != null) {
      widget.onSheetClosed!(newCollection);
    }
  }
}
