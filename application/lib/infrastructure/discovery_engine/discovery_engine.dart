import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';

import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/next_feed_batch_request_failed.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/next_feed_batch_request_succeeded.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/restore_feed_failed.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/restore_feed_succeeded.dart';
import 'package:xayn_discovery_app/domain/model/legacy/mappers/document_response_codec.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

@singleton
class DiscoveryEngine {
  final tokenHeaderName = 'authorizationToken';
  final String userId;
  final Uri endpoint = Uri.parse(Env.searchApiBaseUrl);
  final String token = Env.searchApiSecretKey;
  final http.Client client = http.Client();
  final StreamController<EngineEvent> _engineEventsController =
      StreamController<EngineEvent>();
  final Set<DocumentId> _sessionCache = <DocumentId>{};
  late final _restoredItems = _loadRandomDocuments();

  DiscoveryEngine._(this.userId);

  factory DiscoveryEngine() {
    final userId = const Uuid().v4();

    return DiscoveryEngine._(userId);
  }

  Stream<EngineEvent> get engineEvents => _engineEventsController.stream;

  Future<EngineEvent> restoreFeed() async {
    late final EngineEvent engineEvent;

    try {
      final items = await _restoredItems;

      engineEvent = RestoreFeedSucceeded(items
          .where((it) => _sessionCache.add(it.documentId))
          .toList(growable: false));
    } catch (e, s) {
      logger.e('restoreFeed exception: $e - $s');

      engineEvent = const RestoreFeedFailed();
    }

    _engineEventsController.add(engineEvent);

    return engineEvent;
  }

  Future<EngineEvent> requestNextFeedBatch() async {
    const decoder = DocumentResponseDecoder();
    final url = endpoint
        .resolve('default/users/$userId/personalized_documents')
        .replace(queryParameters: const {'count': '40'});
    final response = await client.get(url, headers: {
      tokenHeaderName: token,
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      logger.e(
          '[${response.statusCode}] requestNextFeedBatch failed\n${response.body}');

      final engineEvent = response.statusCode == 409
          ? NextFeedBatchRequestSucceeded(await _loadRandomDocuments())
          : const NextFeedBatchRequestFailed();

      _engineEventsController.add(engineEvent);

      return engineEvent;
    }

    final json =
        const JsonDecoder().convert(_extractResponseBody(response.bodyBytes));
    final documents = json['documents'] as List;
    final items = documents
        .cast<Map<String, dynamic>>()
        .map(decoder.convert)
        .toList(growable: false);
    final uniqueItems = <Document>{};
    var index = 0;

    while (uniqueItems.length < 2) {
      final next = items[index];

      if (_sessionCache.add(next.documentId)) {
        uniqueItems.add(next);
      }

      index++;
    }

    final engineEvent =
        NextFeedBatchRequestSucceeded(uniqueItems.toList(growable: false));

    logger.i('requestNextFeedBatch succeeded, ${uniqueItems.length} received');

    _engineEventsController.add(engineEvent);

    return engineEvent;
  }

  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) async {
    final url = endpoint.resolve('default/users/$userId/interactions');
    final response = await client.patch(url,
        headers: {
          tokenHeaderName: token,
          'Content-Type': 'application/json',
        },
        body: const JsonEncoder().convert({
          'documents': [
            {
              'id': documentId.value,
              'type': 'Positive',
            }
          ],
        }));

    if (response.statusCode == 204) {
      logger.i('patched interaction for documentId: $documentId');
    } else {
      logger.e(
          '[${response.statusCode}] could not patch interaction for documentId: $documentId\n${response.body}');
    }

    const engineEvent = ClientEventSucceeded();

    _engineEventsController.add(engineEvent);

    return engineEvent;
  }

  Future<EngineEvent> logDocumentTime({
    required DocumentId documentId,
    required int seconds,
    required DocumentViewMode mode,
  }) async =>
      const ClientEventSucceeded();

  Future<List<Document>> _loadRandomDocuments() async {
    final random = Random();
    const decoder = DocumentResponseDecoder();

    final json = await rootBundle.loadString('assets/data_set.json');
    final decoded = const JsonDecoder().convert(json) as List;
    final rndData = List<Map>.generate(
        2, (_) => decoded[random.nextInt(decoded.length)] as Map);

    return rndData
        .cast<Map<String, dynamic>>()
        .map(decoder.convert)
        .toList(growable: false);
  }

  String _extractResponseBody(List<int> bytes) {
    try {
      // we did a request for utf-8...
      const decoder = Utf8Codec();

      return decoder.decode(bytes);
    } catch (e) {
      // ...unfortunately some sites still then return eg iso-8859-1
      const decoder = Latin1Codec();

      return decoder.decode(bytes);
    }
  }
}
