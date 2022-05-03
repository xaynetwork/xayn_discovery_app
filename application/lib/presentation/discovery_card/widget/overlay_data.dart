import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_design/xayn_design.dart' as design;
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/widget/document_filter_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/generic_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'overlay_data.freezed.dart';

/// Simple Marker Interface.
class OverlayData {
  OverlayData._();

  /// Tooltips
  ///
  static const maxDisplayableCollectionName = 20;

  static tooltipBookmarked({
    required Document document,
    required VoidCallback onTap,
  }) {
    var defaultCollectionName = R.strings.defaultCollectionNameReadLater
        .truncate(maxDisplayableCollectionName);
    final label =
        R.strings.bookmarkSnackBarSavedTo.format(defaultCollectionName);
    return _wrapTooltip(design.TooltipData.customized(
      highlightText: defaultCollectionName,
      key: 'bookmarkedToDefault',
      label: label,
      onTap: onTap,
      icon: R.assets.icons.edit,
    ));
  }

  static tooltipDocumentFilter({
    required VoidCallback onTap,
  }) =>
      _wrapTooltip(
        design.TooltipData.customized(
          key: 'documentFilter',
          label: R.strings.sourceHandlingTooltipLabel,
          highlightText: R.strings.sourceHandlingTooltipHighlightedWord,
          onTap: onTap,
        ),
      );

  static tooltipInvalidSearch() => _wrapTooltip(design.TooltipData.customized(
        key: 'invalidSearch',
        label: R.strings.invalidSearch,
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      ));

  static tooltipErrorMaxSelectedCountries(int maxSelectedCounties) =>
      _wrapTooltip(design.TooltipData.customized(
        key: 'feedSettingsScreenMaxSelectedCountries',
        label: R.strings.feedSettingsScreenMaxSelectedCountriesError
            .format(maxSelectedCounties.toString()),
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      ));

  static tooltipErrorMinSelectedCountries() =>
      _wrapTooltip(design.TooltipData.customized(
        key: 'feedSettingsScreenMinSelectedCountries',
        label: R.strings.feedSettingsScreenMinSelectedCountriesError,
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      ));

  static tooltipError(design.TooltipData data) => _wrapTooltip(data);

  static tooltipTextError(String text) =>
      _wrapTooltip(design.TooltipData.textual(key: text, label: text));

  static _wrapTooltip(design.TooltipData data) =>
      _TooltipOverlayData.tooltip(data: data);

  /// BottomSheets
  ///
  static bottomSheetDocumentFilter(Document document) =>
      BottomSheetData<Document>(
          args: document,
          builder: (context, document) =>
              DocumentFilterBottomSheet(document: document!));

  static bottomSheetGenericError({bool allowStacking = false}) =>
      BottomSheetData<Void>(
          allowStacking: allowStacking,
          builder: (context, _) => GenericErrorBottomSheet());

  static bottomSheetMoveDocumentToCollection(
          {required Document document,
          DocumentProvider? provider,
          FeedType? feedType}) =>
      BottomSheetData<Document>(
          args: document,
          builder: (context, document) => MoveDocumentToCollectionBottomSheet(
                document: document!,
                provider: provider,
                feedType: feedType,
              ));
}

@freezed
class _TooltipOverlayData extends OverlayData with _$_TooltipOverlayData {
  const factory _TooltipOverlayData.tooltip({
    required design.TooltipData data,
    // ignore: unused_element
    @Default(design.TooltipStyle.normal) design.TooltipStyle style,
  }) = TooltipData;
}

typedef BottomSheetBuilder<T> = design.BottomSheetBase Function(
    BuildContext context, T args);

class BottomSheetData<T> extends Equatable implements OverlayData {
  final BottomSheetBuilder<T?> builder;
  final T? args;
  final bool allowStacking;

  const BottomSheetData({
    required this.builder,
    this.allowStacking = true,
    this.args,
  });

  design.BottomSheetBase build(BuildContext context) => builder(context, args);

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
