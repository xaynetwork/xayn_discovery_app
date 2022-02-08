import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CollectionToolTipKeys {
  static TooltipKey getKeyByErrorEnum(CollectionUseCaseError error) =>
      _getErrorMap()
          .keys
          .toList(growable: false)
          .firstWhere((it) => it.value == error.name);
}

final collectionMessages = _getErrorMap();

Map<TooltipKey, TooltipParams> _getErrorMap() {
  final mapper = di.get<CollectionErrorsEnumMapper>();
  final _builder = CustomizedTextualNotification(
    labelTextStyle: R.styles.tooltipHighlightTextStyle,
  );

  return {
    for (final it in CollectionUseCaseError.values)
      TooltipKey(it.name): TooltipParams(
        label: mapper.mapEnumToString(it),
        builder: (_) => _builder,
      )
  };
}
