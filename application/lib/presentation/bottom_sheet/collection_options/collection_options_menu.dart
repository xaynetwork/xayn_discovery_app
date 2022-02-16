import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/delete_collection_confirmation_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_card_options/menu_option.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_clickable_option.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CollectionOptionsBottomSheet extends BottomSheetBase {
  CollectionOptionsBottomSheet({
    required Collection collection,
    required VoidCallback onSystemPop,
    Key? key,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _CollectionOptions(
            collection: collection,
            onSystemPop: onSystemPop,
          ),
        );
}

class _CollectionOptions extends StatefulWidget {
  final VoidCallback? onSystemPop;
  final Collection collection;
  const _CollectionOptions({
    this.onSystemPop,
    required this.collection,
  });
  @override
  __CollectionOptionsState createState() => __CollectionOptionsState();
}

class __CollectionOptionsState extends State<_CollectionOptions>
    with BottomSheetBodyMixin {
  @override
  Widget build(BuildContext context) {
    final menuOptions = [
      MenuOption(
          svgIconPath: R.assets.icons.edit,
          text: R.strings.bottomSheetRename,
          onPressed: () {
            closeBottomSheet(context);
            showAppBottomSheet(
              context,
              showBarrierColor: false,
              builder: (context) => CreateOrRenameCollectionBottomSheet(
                onSystemPop: widget.onSystemPop,
                collection: widget.collection,
              ),
            );
          }),
      MenuOption(
        svgIconPath: R.assets.icons.trash,
        text: R.strings.bottomSheetDelete,
        onPressed: () {
          closeBottomSheet(context);
          showAppBottomSheet(
            context,
            showBarrierColor: false,
            builder: (context) => DeleteCollectionConfirmationBottomSheet(
              collectionId: widget.collection.id,
              onSystemPop: widget.onSystemPop,
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
      ],
    );
  }

  Widget _buildRow(MenuOption menuOption) {
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
    return BottomSheetClickableOption(
      child: row,
      onTap: menuOption.onPressed,
    );
  }
}
