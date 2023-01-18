import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';

/// Class containing the error messages that can be found in
/// an engine event when an error occurs
class EngineErrorMessages {
  EngineErrorMessages._();

  static const String timeoutError = 'TimedOut';
  static const String connectError = 'ConnectError';

  /// Use the following when there is no match with anyone else error message
  static const String unknownError = 'Unknown';
}

mixin EngineErrorMessagesMixin {
  /// Checks which error message the engine event contains
  /// and returns it
  String getEngineEventErrorMessage(EngineEvent event) {
    final eventString = event.toString().toLowerCase();
    final timeoutError = EngineErrorMessages.timeoutError.toLowerCase();
    final connectError = EngineErrorMessages.connectError.toLowerCase();
    if (eventString.contains(timeoutError)) {
      return EngineErrorMessages.timeoutError;
    }
    if (eventString.contains(connectError)) {
      return EngineErrorMessages.connectError;
    }
    return EngineErrorMessages.unknownError;
  }
}
