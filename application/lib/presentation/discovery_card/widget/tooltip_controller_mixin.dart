import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/touch_trigger.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/bookmark_messages.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/document_filter_messages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin TooltipControllerMixin<T extends DiscoveryCardBase>
    on DiscoveryCardBaseState<T> {
  late final FeatureManager _featureManager = di.get();
  late StreamSubscription<DiscoveryCardState> _subscription;

  late final TooltipTouchController _tooltipController =
      TooltipTouchController(showBookmarkedTooltip: () {
    showTooltip(
      BookmarkToolTipKeys.bookmarkedToDefault,
      parameters: [
        context,
        widget.document,
        discoveryCardManager.state.processedDocument
            ?.getProvider(widget.document.resource),
        (tooltipKey) => showTooltip(tooltipKey),
      ],
    );
  }, showDocumentFilterTooltip: () {
    if (_featureManager.isDocumentFilterEnabled) {
      showTooltip(
        DocumentFilterKeys.documentFilter,
        parameters: [
          context,
          widget.document,
        ],
      );
    }
  });

  @override
  void initState() {
    super.initState();
    _subscription = discoveryCardManager.stream.listen((event) {
      _tooltipController.onBookmarkStatusChanged(event.bookmarkStatus);
      _tooltipController
          .onUserReactionChanged(event.explicitDocumentUserReaction);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void onBookmarkPressed() {
    _tooltipController.onBookmarkPressed();
    super.onBookmarkPressed();
  }

  @override
  void onFeedbackPressed(UserReaction requested) {
    _tooltipController.onFeedbackPressed();
    super.onFeedbackPressed(requested);
  }
}

class TooltipTouchController {
  final VoidCallback _showBookmarkedTooltip;
  final VoidCallback _showDocumentFilterTooltip;

  late final _bookmarkedTouchTrigger = TouchTrigger<BookmarkStatus>(
    triggerCondition: (last, current) => current == BookmarkStatus.bookmarked,
    trigger: (_) => _showBookmarkedTooltip(),
  );

  late final _feedbackTouchTrigger = TouchTrigger<UserReaction>(
    triggerCondition: (last, current) => current == UserReaction.negative,
    trigger: (_) => _showDocumentFilterTooltip(),
  );

  TooltipTouchController({
    required VoidCallback showBookmarkedTooltip,
    required VoidCallback showDocumentFilterTooltip,
  })  : _showBookmarkedTooltip = showBookmarkedTooltip,
        _showDocumentFilterTooltip = showDocumentFilterTooltip;

  void onFeedbackPressed() {
    _feedbackTouchTrigger.onTouched();
  }

  void onBookmarkPressed() {
    _bookmarkedTouchTrigger.onTouched();
  }

  void onBookmarkStatusChanged(BookmarkStatus status) {
    _bookmarkedTouchTrigger.onStateChanged(status);
  }

  void onUserReactionChanged(UserReaction userReaction) {
    _feedbackTouchTrigger.onStateChanged(userReaction);
  }
}
