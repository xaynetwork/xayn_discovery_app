import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';

enum EngineExceptionReason { wrongEventInResponse }

class EngineExceptionRaised implements EngineEvent {
  final EngineExceptionReason reason;

  const EngineExceptionRaised(this.reason);
}
