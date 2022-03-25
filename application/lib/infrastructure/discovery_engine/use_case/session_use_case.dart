import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/session/session.dart';

@injectable
class FetchSessionUseCase extends UseCase<None, Session> {
  final SessionStore _sessionStore;

  FetchSessionUseCase(this._sessionStore);

  @override
  Stream<Session> transaction(None param) async* {
    yield* _sessionStore.onSession.take(1);
  }
}

@injectable
class UpdateSessionUseCase extends UseCase<Session, Session> {
  final SessionStore _sessionStore;

  UpdateSessionUseCase(this._sessionStore);

  @override
  Stream<Session> transaction(Session param) async* {
    _sessionStore.updateSession(param);

    yield param;
  }
}

abstract class SessionStore {
  Stream<Session> get onSession;

  void updateSession(Session session);
}

@Singleton(as: SessionStore)
class SessionLocalStore implements SessionStore {
  late final BehaviorSubject<Session> _subject = BehaviorSubject<Session>();

  @visibleForTesting
  SessionLocalStore({required Session sessionStart}) {
    _subject.add(sessionStart);
  }

  @factoryMethod
  SessionLocalStore.autowired() {
    _subject.add(Session.start());
  }

  @override
  Stream<Session> get onSession => _subject.stream;

  @override
  void updateSession(Session session) => _subject.add(session);
}
