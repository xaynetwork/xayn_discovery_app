import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';

mixin OnBookmarkChangedMixin<T extends DiscoveryCardBase>
    on DiscoveryCardBaseState<T> {
  late final StreamSubscription<Iterable<BookmarkStatus>>
      _bookmarkTooltipSubscription;

  @override
  void initState() {
    super.initState();

    onShowTooltip(_) => showTooltip(
          BookmarkToolTipKeys.bookmarkedToDefault,
          parameters: [
            context,
            widget.document,
            discoveryCardManager.state.processedDocument
                ?.getProvider(widget.document.resource),
            (tooltipKey) => showTooltip(tooltipKey),
          ],
        );

    // the state will always begin with [BookmarkStatus.unknown],
    // then as it gets the value from the repository, it becomes
    // [BookmarkStatus.bookmarked] or [BookmarkStatus.notBookmarked].
    // we are looking for a pattern where it switches from notBookmarked to bookmarked only.
    _bookmarkTooltipSubscription = discoveryCardManager.stream
        .map((it) => it.bookmarkStatus)
        .startWith(discoveryCardManager.state.bookmarkStatus)
        .distinct()
        .pairwise()
        .where((it) =>
            it.first == BookmarkStatus.notBookmarked &&
            it.last == BookmarkStatus.bookmarked)
        .listen(onShowTooltip);
  }

  @override
  void dispose() {
    _bookmarkTooltipSubscription.cancel();

    super.dispose();
  }
}
