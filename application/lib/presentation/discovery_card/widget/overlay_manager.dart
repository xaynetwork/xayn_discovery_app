import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/widget/overlay_data.dart';

typedef OverlayCondition<T> = Function(T? oldState, T newState);

class OverlayManager<T> extends Cubit<List<OverlayData>> {
  final _futureOverlays = <OverlayData, OverlayCondition<T>>{};
  T? _oldState;
  List<OverlayData> _currentVisible = [];

  OverlayManager() : super([]);

  void show(OverlayData data, {OverlayCondition<T>? when}) {
    if (when == null) {
      _currentVisible.add(data);
      _computeState();
    } else {
      _futureOverlays[data] = when;
    }
  }

  void onNewState(T state) {
    final overlays = _futureOverlays.entries.where((data) {
      return data.value(_oldState, state);
    }).toList();
    for (var element in overlays) {
      _futureOverlays.remove(element.key);
    }
    _oldState = state;
    _currentVisible = overlays.map((e) => e.key).toList();
    _computeState();
  }

  void onOverlayRemoved(OverlayData data) {
    if (_currentVisible.remove(data)) {
      _computeState();
    }
  }

  void _computeState() {
    emit(_currentVisible.toList());
  }

  @override
  Future<void> close() {
    _futureOverlays.clear();
    _currentVisible.clear();
    return super.close();
  }
}
