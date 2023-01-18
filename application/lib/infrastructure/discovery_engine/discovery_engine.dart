import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';

import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';

@singleton
class DiscoveryEngine {
  final String userId;
  final StreamController<EngineEvent> _engineEventsController =
      StreamController<EngineEvent>();

  DiscoveryEngine._(this.userId);

  factory DiscoveryEngine() {
    final userId = const Uuid().v4();

    return DiscoveryEngine._(userId);
  }

  Stream<EngineEvent> get engineEvents => _engineEventsController.stream;

  Future<EngineEvent> restoreFeed() async {}

  Future<EngineEvent> requestNextFeedBatch() async {}

  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) async {}

  Future<EngineEvent> logDocumentTime({
    required DocumentId documentId,
    required int seconds,
    required DocumentViewMode mode,
  }) async {}
}
