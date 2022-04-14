import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/widget/document_filter_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

class ActiveSearchKeys {
  static const invalidSearch = TooltipKey('invalidSearch');
}

final sourceHandlingMessages = <TooltipKey, TooltipParams>{
  ActiveSearchKeys.invalidSearch: TooltipParams(
    label: R.strings.sourceHandlingTooltipLabel,
    builder: (_) => CustomizedTextualNotification(
      labelTextStyle: R.styles.tooltipHighlightTextStyle,
    ),
  ),
};
