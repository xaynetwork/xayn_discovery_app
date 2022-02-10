import 'package:xayn_design/xayn_design.dart'
    show
        CustomizedTextualNotification,
        MessageFactory,
        TextualNotification,
        TooltipKey,
        TooltipParams;
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/collection_messages.dart';

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
        builder: (_) => CustomizedTextualNotification(
            labelTextStyle: R.styles.tooltipHighlightTextStyle),
      ),
    };

    return Map.fromEntries(sets.map((it) {
      switch (it) {
        case XaynMessageSet.activeSearch:
          return activeSearchMessages.entries;
        case XaynMessageSet.bookmark:
          return bookmarkMessages.entries;
        case XaynMessageSet.collection:
          return collectionMessages.entries;
      }
    }).expand((it) => it));
  }
}

enum XaynMessageSet {
  activeSearch,
  bookmark,
  collection,
}

typedef OnToolTipError = void Function(TooltipKey);
