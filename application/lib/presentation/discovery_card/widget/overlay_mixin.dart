import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design.dart' as design;
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';

mixin OverlayMixin<T extends StatefulWidget> on State<T> {
  /// Needs to be provided by the state,
  /// usually lives in the Manager that uses a [OverlayManagerMixin]
  OverlayManager get overlayManager;

  late final design.TooltipController _tooltipController;
  late StreamSubscription<List<OverlayData>> _subscription;

  @override
  void initState() {
    super.initState();
    _tooltipController = Provider.of(context, listen: false);
    _subscription = overlayManager.stream.listen((event) {
      for (var e in event) {
        e.map(
          tooltip: (tooltip) => _showTooltip(
            tooltip.data,
          ),
          bottomSheet: (BottomSheetData<dynamic> bottomSheet) {
            showAppBottomSheet(
              context,
              builder: bottomSheet.build,
              allowStacking: bottomSheet.allowStacking,
            );
          },
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

  void _showTooltip(
    design.TooltipData data,
  ) =>
      _tooltipController.show(data);
}
