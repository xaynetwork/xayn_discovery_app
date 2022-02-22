import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';

mixin OnBookmarkChangedMixin<T extends DiscoveryCardBase>
    on DiscoveryCardBaseState<T> {
  late bool _didShowBookmarkTooltip;

  @override
  void initState() {
    super.initState();

    _didShowBookmarkTooltip = discoveryCardManager.state.isBookmarked;
  }

  void onBookmarkChanged(DiscoveryCardState state) {
    if (state.isBookmarkToggled && !_didShowBookmarkTooltip) {
      showTooltip(
        BookmarkToolTipKeys.bookmarkedToDefault,
        parameters: [
          context,
          widget.document,
          state.processedDocument?.getProvider(widget.document.resource),
          (tooltipKey) => showTooltip(tooltipKey),
        ],
      );
    }

    _didShowBookmarkTooltip = state.isBookmarkToggled;
  }
}
