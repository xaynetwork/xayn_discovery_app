import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/widget/document_filter_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

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
    showAppBottomSheet(
      args[0] as BuildContext,
      builder: (_) => DocumentFilterBottomSheet(
        document: args[1] as Document,
      ),
    );
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
