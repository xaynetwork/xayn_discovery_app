import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_card_options/menu_option.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_clickable_option.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CollectionOptionsBottomSheet extends BottomSheetBase {
  CollectionOptionsBottomSheet({
    required Collection collection,
    required VoidCallback onSystemPop,
    required VoidCallback onDeletePressed,
    required VoidCallback onRenamePressed,
    Key? key,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _CollectionOptions(
            collection: collection,
            onSystemPop: onSystemPop,
            onDeletePressed: onDeletePressed,
            onRenamePressed: onRenamePressed,
          ),
        );
}

class _CollectionOptions extends StatefulWidget {
  final VoidCallback? onSystemPop;
  final Collection collection;
  final VoidCallback onDeletePressed;
  final VoidCallback onRenamePressed;

  const _CollectionOptions({
    this.onSystemPop,
    required this.collection,
    required this.onDeletePressed,
    required this.onRenamePressed,
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
          widget.onRenamePressed();
        },
      ),
      MenuOption(
        svgIconPath: R.assets.icons.trash,
        text: R.strings.bottomSheetDelete,
        onPressed: () {
          closeBottomSheet(context);
          widget.onDeletePressed();
        },
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: menuOptions.map(_buildRow).toList(),
    );
  }

  Widget _buildRow(MenuOption menuOption) {
    final leadingIcon = SvgPicture.asset(
      menuOption.svgIconPath,
      color: R.colors.icon,
    );
    final text = Text(menuOption.text, style: R.styles.mBoldStyle);
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
