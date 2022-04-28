import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';

mixin OverlayMixin<T extends StatefulWidget> on TooltipStateMixin<T> {
  /// Needs to be provided by the state,
  /// usually lives in the Manager that uses a [OverlayManagerMixin]
  OverlayManager get overlayManager;

  late StreamSubscription<List<OverlayData>> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = overlayManager.stream.listen((event) {
      for (var e in event) {
        e.map(
          tooltip: (tooltip) => showTooltip(
            tooltip.key,
            style: tooltip.style,
            parameters: <dynamic>[context] + tooltip.tooltipArgs,
          ),
        );

        overlayManager.onOverlayRemoved(e);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
