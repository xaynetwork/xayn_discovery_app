import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ActiveSearchTooltipKeys {
  static const invalidSearch = TooltipKey('invalidSearch');
}

final activeSearchMessages = {
  ActiveSearchTooltipKeys.invalidSearch: TooltipParams(
    label: R.strings.invalidSearch,
    builder: (_) => CustomizedTextualNotification(
      labelTextStyle: R.styles.tooltipHighlightTextStyle,
    ),
  ),
};
