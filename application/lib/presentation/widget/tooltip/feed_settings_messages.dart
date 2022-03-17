import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/feed_settings_error.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';

class FeedSettingsKeys {
  static TooltipKey getKeyByErrorEnum(FeedSettingsError error) {
    switch (error) {
      case FeedSettingsError.minSelectedCountries:
        return TooltipKeys.feedSettingsScreenMinSelectedCountries;
      case FeedSettingsError.maxSelectedCountries:
        return TooltipKeys.feedSettingsScreenMaxSelectedCountries;
    }
  }
}
