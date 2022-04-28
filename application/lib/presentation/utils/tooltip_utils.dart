import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/collections/util/collection_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class TooltipUtils {
  static TooltipData? getErrorData(Object? error) {
    if (error == null) return null;

    TooltipData? data;

    if (error is BookmarkUseCaseError) {
      final mapper = di.get<BookmarkErrorsEnumMapper>();
      data = TooltipData.customized(
        key: error.name,
        label: mapper.mapEnumToString(error),
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      );
    } else if (error is CollectionUseCaseError) {
      final mapper = di.get<CollectionErrorsEnumMapper>();
      data = TooltipData.customized(
        key: error.name,
        label: mapper.mapEnumToString(error),
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      );
    }

    return data;
  }

  static TooltipData feedSettingsScreenMaxSelectedCountries(
          int maxSelectedCountryAmount) =>
      TooltipData.customized(
        key: 'feedSettingsScreenMaxSelectedCountries',
        label: R.strings.feedSettingsScreenMaxSelectedCountriesError
            .format(maxSelectedCountryAmount.toString()),
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      );
}
