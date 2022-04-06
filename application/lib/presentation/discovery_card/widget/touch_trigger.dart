import 'dart:math';

typedef TriggerCondition<T> = bool Function(T? oldValue, T newValue);
typedef Trigger<T> = Function(T newValue);

/// A Class to model a two stages trigger.
/// 1. a touch event is registered (Button.onPressed -> trigger.onTouch())
/// 2. a state change is caused by the manager (Manager.listen { state -> trigger.onStateChanged(sate) } )
/// 3. the trigger calls on [Trigger] when the [TriggerCondition] is true
class TouchTrigger<T> {
  final _random = Random();
  final TriggerCondition<T> _triggerCondition;
  final Trigger<T> _trigger;

  int? _touchTag;
  int? _lastUsedTouchTag;
  T? _lastState;

  TouchTrigger(
      {required TriggerCondition triggerCondition, required Trigger trigger})
      : _trigger = trigger,
        _triggerCondition = triggerCondition;

  void onTouched() {
    _touchTag = _random.nextInt(100000);
  }

  void onStateChanged(T newState) {
    if (_lastUsedTouchTag != _touchTag &&
        _triggerCondition(_lastState, newState)) {
      _lastUsedTouchTag = _touchTag;
      _trigger(newState);
    }
    _lastState = newState;
  }
}
