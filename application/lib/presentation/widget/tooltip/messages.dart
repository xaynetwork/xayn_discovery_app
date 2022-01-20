import 'package:xayn_design/xayn_design.dart'
    show MessageFactory, TooltipParams, TooltipKey, TextualNotification;
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class TooltipKeys {
  static const activeSearchDisabled = TooltipKey('activeSearchDisabled');
  static const feedSettingsScreenMaxSelectedCountries =
      TooltipKey('feedSettingsScreenMaxSelectedCountries');
  static const feedSettingsScreenMinSelectedCountries =
      TooltipKey('feedSettingsScreenMinSelectedCountries');
}

abstract class XaynMessageProvider {
  XaynMessageProvider._();

  static MessageFactory of(Iterable<XaynMessageSet> sets) {
    const _defaultMessage = TextualNotification();
    final activeSearchMessages = {
      TooltipKeys.activeSearchDisabled: TooltipParams(
        label: R.strings.comingSoon,
        builder: (_) => _defaultMessage,
      ),
      TooltipKeys.feedSettingsScreenMinSelectedCountries: TooltipParams(
        label: R.strings.feedSettingsScreenMinSelectedCountriesError,
        builder: (_) => _defaultMessage,
      ),
    };

    return Map.fromEntries(sets.map((it) {
      switch (it) {
        case XaynMessageSet.activeSearch:
          return activeSearchMessages.entries;
      }
    }).expand((it) => it));
  }
}

enum XaynMessageSet {
  activeSearch,
}
