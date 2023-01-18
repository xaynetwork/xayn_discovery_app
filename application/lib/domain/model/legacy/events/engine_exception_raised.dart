import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';

class EngineExceptionRaised implements EngineEvent {
  final String message;

  const EngineExceptionRaised(this.message);
}
