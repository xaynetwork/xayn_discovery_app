import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/add_collection/manager/create_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/widget/app_text_field.dart';
import 'package:xayn_discovery_app/presentation/widget/bottom_sheet.dart';

class AddCollectionBottomSheet extends BottomSheetBase {
  const AddCollectionBottomSheet({Key? key})
      : super(
          key: key,
          body: const _AddCollection(),
        );
}

class _AddCollection extends StatefulWidget {
  const _AddCollection({Key? key}) : super(key: key);

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
      hintText: 'Collection name',
      onChanged: updateCollectionName,
    );

    const header = Text('Create a new Collection');

    final footer = BottomSheetFooter(
      onCancelPressed: () => closeBottomSheet(context),
      onApplyPressed: onApplyPressed,
      isApplyDisabled: collectionName == null || collectionName!.isEmpty,
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

  void onApplyPressed() {
    _createCollectionManager.createCollection(collectionName!);
    closeBottomSheet(context);
  }
}
