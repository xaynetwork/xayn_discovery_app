import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_collection/widget/create_or_rename_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation.dart/delete_collection_confirmation_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CollectionOptionsBottomSheet extends BottomSheetBase {
  CollectionOptionsBottomSheet({
    required UniqueId collectionId,
    VoidCallback? onSystemPop,
    Key? key,
  }) : super(
          key: key,
          body: _CollectionOptions(
            collectionId: collectionId,
            onSystemPop: onSystemPop,
          ),
        );
}

class _CollectionOptions extends StatefulWidget {
  final VoidCallback? onSystemPop;
  final UniqueId collectionId;
  const _CollectionOptions({
    this.onSystemPop,
    required this.collectionId,
  });
  @override
  __CollectionOptionsState createState() => __CollectionOptionsState();
}

class __CollectionOptionsState extends State<_CollectionOptions>
    with BottomSheetBodyMixin {
  @override
  Widget build(BuildContext context) {
    final menuOptions = [
      _MenuOption(
          svgIconPath: R.assets.icons.edit,
          text: R.strings.bottomSheetRename,
          onPressed: () {
            closeBottomSheet(context);
            showAppBottomSheet(
              context,
              builder: (context) => CreateOrRenameCollectionBottomSheet(
                collectionId: widget.collectionId,
              ),
            );
          }),
      _MenuOption(
        svgIconPath: R.assets.icons.trash,
        text: R.strings.bottomSheetDelete,
        onPressed: () {
          closeBottomSheet(context);
          showAppBottomSheet(
            context,
            builder: (context) => DeleteCollectionConfirmationBottomSheet(
              collectionId: widget.collectionId,
            ),
          );
        },
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: R.dimen.unit2),
        ...menuOptions.map(_buildRow).toList(),
        SizedBox(height: R.dimen.unit2),
      ],
    );
  }

  Widget _buildRow(_MenuOption menuOption) {
    final leadingIcon = SvgPicture.asset(menuOption.svgIconPath);
    final text = Text(menuOption.text, style: R.styles.bottomSheetText);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        leadingIcon,
        SizedBox(width: R.dimen.unit2),
        text,
      ],
    );
    return InkWell(
      onTap: menuOption.onPressed,
      child: SizedBox(
        child: row,
        height: R.dimen.unit6,
      ),
    );
  }
}

class _MenuOption {
  final String svgIconPath;
  final String text;
  final VoidCallback onPressed;

  _MenuOption({
    required this.svgIconPath,
    required this.text,
    required this.onPressed,
  });
}
