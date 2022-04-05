import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/document_filter_messages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin OnBookmarkChangedMixin<T extends DiscoveryCardBase>
    on DiscoveryCardBaseState<T> {
  late bool _didShowBookmarkTooltip;
  late bool _didShowDocumentFilterTooltip;
  late final FeatureManager _featureManager = di.get();

  @override
  void initState() {
    super.initState();

    _didShowBookmarkTooltip = discoveryCardManager.state.isBookmarked;
    _didShowDocumentFilterTooltip =
        discoveryCardManager.state.explicitDocumentUserReaction ==
            UserReaction.negative;
  }

  void onDiscoveryCardStateChanged(DiscoveryCardState state) {
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

    if (_featureManager.isDocumentFilterEnabled) {
      if (state.explicitDocumentUserReaction == UserReaction.negative &&
          !_didShowDocumentFilterTooltip) {
        showTooltip(
          DocumentFilterKeys.documentFilter,
          parameters: [
            context,
            widget.document,
          ],
        );
      }
    }

    _didShowBookmarkTooltip = state.isBookmarkToggled;
    _didShowDocumentFilterTooltip =
        state.explicitDocumentUserReaction == UserReaction.negative;
  }
}
