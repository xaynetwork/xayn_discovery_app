import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/widget/bottom_sheet.dart';

class AddCollectionBottomSheet extends BottomSheetBase {
  const AddCollectionBottomSheet({Key? key})
      : super(
          key: key,
          body: const _AddCollection(),
        );
}

class _AddCollection extends StatelessWidget {
  const _AddCollection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Add Collection');
  }
}
