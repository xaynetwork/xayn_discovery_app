import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

/// Used for reporting, the sessionID is refreshed every time the app starts.
@singleton
class SessionId {
  final UniqueId key;

  SessionId() : key = UniqueId();
}
