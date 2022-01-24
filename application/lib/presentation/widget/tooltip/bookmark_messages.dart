import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const maxDisplayableCollectionName = 20;

final bookmarkMessages = <TooltipKey, TooltipParams>{
  TooltipKeys.bookmarkedToDefault: _getBookmarkedToDefault(),
};

TooltipParams _getBookmarkedToDefault() {
  final defaultCollectionName = R.strings.defaultCollectionNameReadLater
      .truncate(maxDisplayableCollectionName);

  final savedToDefaultString =
      R.strings.bookmarkSnackBarSavedTo.replaceAll('%s', defaultCollectionName);

  void onPressed(List? args) {
    if (args == null || args.length < 2) return;
    final context = args[0];
    final document = args[1];
    if (context is! BuildContext || document is! Document) return;

    showAppBottomSheet(
      context,
      builder: (_) => MoveDocumentToCollectionBottomSheet(
        document: document,
      ),
    );
  }

  final content = CustomizedTextualNotification(
    onTap: onPressed,
    icon: R.assets.icons.edit,
    highlightText: defaultCollectionName,
  );

  return TooltipParams(
    label: savedToDefaultString,
    builder: (_) => content,
  );
}
