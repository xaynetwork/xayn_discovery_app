import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const maxDisplayableCollectionName = 20;

class BookmarkToolTipKeys {
  static const bookmarkedToDefault = TooltipKey('bookmarkedToDefault');

  static TooltipKey getKeyByErrorEnum(BookmarkUseCaseError error) =>
      _getErrorMap()
          .keys
          .toList(growable: false)
          .firstWhere((it) => it.value == error.name);
}

final bookmarkMessages = <TooltipKey, TooltipParams>{
  ...{BookmarkToolTipKeys.bookmarkedToDefault: _getBookmarkedToDefault()},
  ..._getErrorMap(),
};

TooltipParams _getBookmarkedToDefault() {
  final defaultCollectionName = R.strings.defaultCollectionNameReadLater
      .truncate(maxDisplayableCollectionName);

  final savedToDefaultString =
      R.strings.bookmarkSnackBarSavedTo.format(defaultCollectionName);

  void onPressed(List? args) {
    if (args == null || args.length < 5) return;
    final context = args[0];
    final document = args[1];
    final provider = args[2];
    final onError = args[3];
    final feedType = args[4];
    if (context is! BuildContext ||
        document is! Document ||
        onError is! Function(OverlayData) ||
        feedType is! FeedType ||
        provider is! DocumentProvider?) return;

    showAppBottomSheet(
      context,
      builder: (_) => MoveDocumentToCollectionBottomSheet(
        document: document,

        /// TODO convert onError to nativly use OverlayData
        onError: (key) => onError(OverlayData.tooltip(key: key)),
        provider: provider,
        feedType: feedType,
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

Map<TooltipKey, TooltipParams> _getErrorMap() {
  final mapper = di.get<BookmarkErrorsEnumMapper>();
  final _builder = CustomizedTextualNotification(
    labelTextStyle: R.styles.tooltipHighlightTextStyle,
  );

  return {
    for (final it in BookmarkUseCaseError.values)
      TooltipKey(it.name): TooltipParams(
        label: mapper.mapEnumToString(it),
        builder: (_) => _builder,
      )
  };
}
