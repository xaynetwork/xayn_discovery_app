import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

/// Used for reporting, the sessionID is refreshed every time the app starts.
@singleton
class SessionId {
  static late final SessionId _instance = SessionId._();
  final UniqueId key;

  SessionId._() : key = UniqueId();

  @factoryMethod
  factory SessionId() => _instance;
}
