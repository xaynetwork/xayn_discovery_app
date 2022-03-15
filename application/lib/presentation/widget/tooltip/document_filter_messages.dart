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
    // showAppBottomSheet(
    //   context,
    //   builder: (_) => MoveDocumentToCollectionBottomSheet(
    //     document: document,
    //     onError: onError,
    //     provider: provider,
    //   ),
    // );
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
