import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/document_filter_messages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'overlay_data.freezed.dart';

@freezed
class OverlayData with _$OverlayData {
  const factory OverlayData.tooltip({
    required TooltipKey key,
    @Default(TooltipStyle.normal) TooltipStyle style,
    @Default([]) List<dynamic> tooltipArgs,
  }) = TooltipData;

  factory OverlayData.tooltipBookmarked({
    required Document document,
    required DocumentProvider? provider,
    required FeedType? feedType,
    required Function(TooltipData) showTooltip,
  }) =>
      OverlayData.tooltip(
        key: BookmarkToolTipKeys.bookmarkedToDefault,
        tooltipArgs: [
          document,
          provider,
          showTooltip,
          feedType,
        ],
      );

  factory OverlayData.tooltipDocumentFilter({
    required Document document,
  }) =>
      OverlayData.tooltip(
        key: DocumentFilterKeys.documentFilter,
        tooltipArgs: [
          document,
        ],
      );
}
