import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_manager.dart';

mixin OverlayManagerMixin<T> on Cubit<T> {
  late final _overlayManager = OverlayManager<T>();
  StreamSubscription? _subscription;

  OverlayManager<T> get overlayManager {
    _subscription ??= stream.listen((event) {
      overlayManager.onNewState(event);
    });
    return _overlayManager;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _subscription = null;
    return super.close();
  }

  void showOverlay(OverlayData data, {OverlayCondition<T>? when}) =>
      overlayManager.show(data, when: when);
}
