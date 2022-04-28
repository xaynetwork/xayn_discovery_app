import 'package:flutter/cupertino.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class DocumentFilterKeys {
  static const documentFilter = TooltipKey('documentFilter');
}

final sourceHandlingMessages = <TooltipKey, TooltipParams>{
  DocumentFilterKeys.documentFilter: _getDocumentFilter()
};

TooltipParams _getDocumentFilter() {
  void onPressed(List? args) {
    if (args == null || args.length != 2) {
      throw "No / or not required arguments provided for showing DocumentFilterBottomSheet";
    }
    var onTapCallback = args[1] as VoidCallback;
    onTapCallback();
  }

  final content = CustomizedTextualNotification(
    onTap: onPressed,
    icon: R.assets.icons.edit,
    highlightText: R.strings.sourceHandlingTooltipHighlightedWord,
  );

  return TooltipParams(
    label: R.strings.sourceHandlingTooltipLabel,
    builder: (_) => content,
  );
}
