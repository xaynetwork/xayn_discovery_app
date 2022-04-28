import 'package:xayn_design/xayn_design.dart'
    show
        CustomizedTextualNotification,
        MessageFactory,
        TooltipKey,
        TooltipParams;
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/active_search_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/collection_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/document_filter_messages.dart';

class TooltipKeys {
  static const feedSettingsScreenMaxSelectedCountries =
      TooltipKey('feedSettingsScreenMaxSelectedCountries');
  static const feedSettingsScreenMinSelectedCountries =
      TooltipKey('feedSettingsScreenMinSelectedCountries');
  static const paymentError = TooltipKey('paymentError');
}

abstract class XaynMessageProvider {
  XaynMessageProvider._();

  static MessageFactory of(Iterable<XaynMessageSet> sets) {
    final settingsMessages = {
      TooltipKeys.feedSettingsScreenMinSelectedCountries: TooltipParams(
        label: R.strings.feedSettingsScreenMinSelectedCountriesError,
        builder: (_) => CustomizedTextualNotification(
            labelTextStyle: R.styles.tooltipHighlightTextStyle),
      ),
    };

    return Map.fromEntries(sets.map((it) {
      switch (it) {
        case XaynMessageSet.activeSearch:
          return [...activeSearchMessages.entries, ...settingsMessages.entries];
        case XaynMessageSet.bookmark:
          return bookmarkMessages.entries;
        case XaynMessageSet.collection:
          return collectionMessages.entries;
        case XaynMessageSet.sourceHandling:
          return sourceHandlingMessages.entries;
      }
    }).expand((it) => it));
  }
}

enum XaynMessageSet {
  activeSearch,
  bookmark,
  collection,
  sourceHandling,
}

typedef OnToolTipError = void Function(TooltipKey);
