import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/widget/document_filter_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/active_search_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/document_filter_messages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'overlay_data.freezed.dart';

/// Simple Marker Interface.
class OverlayData {
  OverlayData._();

  /// Tooltips
  ///
  static tooltipBookmarked({
    required Document document,
    required DocumentProvider? provider,
    required FeedType? feedType,
    required Function(TooltipData) showTooltip,
  }) =>
      _TooltipOverlayData.tooltip(
        key: BookmarkToolTipKeys.bookmarkedToDefault,
        tooltipArgs: [
          document,
          provider,
          showTooltip,
          feedType,
        ],
      );

  static tooltipDocumentFilter({
    required VoidCallback onTap,
  }) =>
      _TooltipOverlayData.tooltip(
        key: DocumentFilterKeys.documentFilter,
        tooltipArgs: [
          onTap,
        ],
      );

  static tooltipInvalidSearch() => const _TooltipOverlayData.tooltip(
      key: ActiveSearchTooltipKeys.invalidSearch);

  static tooltipError(TooltipKey key) => _TooltipOverlayData.tooltip(key: key);

  /// BottomSheets
  ///
  static bottomSheetDocumentFilter(Document document) =>
      BottomSheetData<Document>(
          args: document,
          builder: (context, document) =>
              DocumentFilterBottomSheet(document: document!));
}

@freezed
class _TooltipOverlayData extends OverlayData with _$_TooltipOverlayData {
  const factory _TooltipOverlayData.tooltip({
    required TooltipKey key,
    // ignore: unused_element
    @Default(TooltipStyle.normal) TooltipStyle style,
    @Default([]) List<dynamic> tooltipArgs,
  }) = TooltipData;
}

typedef BottomSheetBuilder<T> = BottomSheetBase Function(
    BuildContext context, T args);

class BottomSheetData<T> extends Equatable implements OverlayData {
  final BottomSheetBuilder<T?> builder;
  final T? args;

  const BottomSheetData({
    required this.builder,
    this.args,
  });

  BottomSheetBase build(BuildContext context) => builder(context, args);

  @override
  List<Object?> get props => [builder, args];
}

extension OverlayDataExtension on OverlayData {
  void map({
    required void Function(TooltipData tooltip) tooltip,
    required void Function(BottomSheetData bottomSheet) bottomSheet,
  }) {
    if (this is _TooltipOverlayData) {
      (this as _TooltipOverlayData).map(tooltip: tooltip);
    } else if (this is BottomSheetData) {
      bottomSheet((this as BottomSheetData));
    } else {
      throw "Unimplemented OverlayData type: $this";
    }
  }
}
