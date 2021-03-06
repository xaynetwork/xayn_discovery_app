import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_card_options/menu_option.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_clickable_option.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../../bookmark/manager/bookmarks_screen_manager.dart';

class BookmarkOptionsBottomSheet extends BottomSheetBase {
  BookmarkOptionsBottomSheet({
    required UniqueId bookmarkId,
    required VoidCallback onSystemPop,
    required VoidCallback onMovePressed,
    Key? key,
  }) : super(
          key: key,
          onSystemPop: onSystemPop,
          body: _BookmarkOptions(
              bookmarkId: bookmarkId,
              onSystemPop: onSystemPop,
              onMovePressed: onMovePressed),
        );
}

class _BookmarkOptions extends StatefulWidget {
  final UniqueId bookmarkId;
  final VoidCallback? onSystemPop;
  final VoidCallback onMovePressed;

  const _BookmarkOptions({
    required this.bookmarkId,
    required this.onMovePressed,
    this.onSystemPop,
  });

  @override
  __BookmarkOptionsState createState() => __BookmarkOptionsState();
}

class __BookmarkOptionsState extends State<_BookmarkOptions>
    with BottomSheetBodyMixin {
  late final _bookmarkManager = di.get<BookmarksScreenManager>();

  @override
  Widget build(BuildContext context) {
    final menuOptions = [
      MenuOption(
          svgIconPath: R.assets.icons.move,
          text: R.strings.bottomSheetMoveSingleBookmark,
          onPressed: () {
            closeBottomSheet(context);
            widget.onMovePressed();
          }),
      MenuOption(
        svgIconPath: R.assets.icons.trash,
        text: R.strings.bottomSheetDelete,
        onPressed: () {
          closeBottomSheet(context);
          widget.onSystemPop?.call();
          _bookmarkManager.onDeleteSwipe(widget.bookmarkId);
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
      onTap: menuOption.onPressed,
      child: row,
    );
  }
}
