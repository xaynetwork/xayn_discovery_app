import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design.dart' as design;
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager_mixin.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

void useOverlay<S>(OverlayManager<S> overlayManager) {
  use(_OverlayHook<S>(overlayManager));
}

class _OverlayHook<S> extends Hook<void> {
  const _OverlayHook(this.overlayManager, {List<Object?>? keys})
      : super(keys: keys);

  final OverlayManager<S> overlayManager;

  @override
  HookState<void, _OverlayHook> createState() => _OverlayHookState<S>();
}

class _OverlayHookState<S> extends HookState<void, _OverlayHook> {
  late final design.TooltipController _tooltipController;
  late StreamSubscription<List<OverlayData>> _subscription;

  @override
  void build(BuildContext context) {}

  @override
  void didUpdateHook(_OverlayHook oldHook) {
    super.didUpdateHook(oldHook);
    if (oldHook.overlayManager != hook.overlayManager) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void initHook() {
    super.initHook();
    _tooltipController = Provider.of(context, listen: false);
    _subscribe();
  }

  void _subscribe() {
    _subscription =
        hook.overlayManager.stream.listen(_onEvent, onError: (e, st) {
      logger.e('Error in OverlayManager', e, st);
    });
  }

  _onEvent(List<OverlayData> event) {
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
            isDismissible: bottomSheet.isDismissible,
            showBarrierColor: bottomSheet.showBarrierColor,
          );
        },
      );

      hook.overlayManager.onOverlayRemoved(e);
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _unsubscribe() {
    _subscription.cancel();
  }

  void _showTooltip(
    design.TooltipData data,
  ) =>
      _tooltipController.show(data);
}

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
    design.TooltipData data,
  ) =>
      _tooltipController.show(data);
}
