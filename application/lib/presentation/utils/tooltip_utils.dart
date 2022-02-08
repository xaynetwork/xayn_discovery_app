import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/collection_messages.dart';

class TooltipUtils {
  static TooltipKey? getErrorKey(Object? error) {
    if (error == null) return null;

    TooltipKey? key;

    if (error is BookmarkUseCaseError) {
      key = BookmarkToolTipKeys.getKeyByErrorEnum(error);
    } else if (error is CollectionUseCaseError) {
      key = CollectionToolTipKeys.getKeyByErrorEnum(error);
    }

    return key;
  }
}
