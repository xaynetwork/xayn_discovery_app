import 'package:flutter/widgets.dart';

import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/discovery_card_base.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/document_filter_messages.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin OnReactionChangedMixin<T extends DiscoveryCardBase>
    on DiscoveryCardBaseState<T> {
  late final FeatureManager _featureManager = di.get();

  @override
  void didUpdateWidget(T oldWidget) {
    if (_featureManager.isDocumentFilterEnabled) {
      // we only want to show the reaction tooltip when the reaction
      // value changed from *any* to negative.
      final didBecomeNegative =
          oldWidget.document.userReaction != UserReaction.negative &&
              widget.document.userReaction == UserReaction.negative;

      if (didBecomeNegative) {
        // since we are inside of a build phase here, we cannot call
        // showTooltip sync, or it complains.
        WidgetsBinding.instance!.endOfFrame.whenComplete(() => showTooltip(
              DocumentFilterKeys.documentFilter,
              parameters: [
                context,
                widget.document,
              ],
            ));
      }
    }

    super.didUpdateWidget(oldWidget);
  }
}
