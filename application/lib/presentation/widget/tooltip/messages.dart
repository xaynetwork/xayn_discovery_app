import 'package:xayn_design/xayn_design.dart'
    show MessageFactory, TooltipParams, TooltipKey, TextualNotification;

class TooltipKeys {
  static const activeSearchDisabled = TooltipKey('activeSearchDisabled');
}

abstract class XaynMessageProvider {
  XaynMessageProvider._();

  static MessageFactory of(Iterable<XaynMessageSet> sets) {
    const _defaultMessage = TextualNotification();
    final activeSearchMessages = {
      TooltipKeys.activeSearchDisabled: TooltipParams(
          label: 'Active Search disabled', // R.strings...
          builder: (_) => _defaultMessage),
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
