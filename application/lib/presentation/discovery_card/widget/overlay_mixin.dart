import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  VoidCallback? _lastCloseListeners;

  @override
  void initState() {
    super.initState();
    _tooltipController = Provider.of(context, listen: false);
    _subscription = overlayManager.stream.listen((event) {
      for (var e in event) {
        e.map(
          tooltip: (tooltip) => _showTooltip(
            tooltip,
          ),
          bottomSheet: (BottomSheetData<dynamic> bottomSheet) {
            design.showAppBottomSheet(
              context,
              builder: bottomSheet.build,
              allowStacking: bottomSheet.allowStacking,
              isDismissible: bottomSheet.isDismissible,
              showBarrierColor: bottomSheet.showBarrierColor,
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
    TooltipData data,
  ) {
    _tooltipController.show(data.data);

    final onClosed = data.onClosed;
    if (onClosed != null) {
      _subscribeForTooltipClose(data, onClosed);
    }
  }

  _subscribeForTooltipClose(TooltipData data, VoidCallback onClosed) {
    void callback() {
      if (_tooltipController.activeTooltipData == null) {
        _tooltipController.removeListener(callback);
        _lastCloseListeners = null;
        onClosed();
      } else if (_tooltipController.activeTooltipData != data.data) {
        _tooltipController.removeListener(callback);
      }
    }

    final lastCloseListener = _lastCloseListeners;
    if (lastCloseListener != null) {
      _tooltipController.removeListener(lastCloseListener);
    }
    _lastCloseListeners = callback;
    _tooltipController.addListener(callback);
  }
}
