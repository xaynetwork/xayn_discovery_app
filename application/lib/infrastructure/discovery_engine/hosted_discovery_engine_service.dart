import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const ok = ClientEventSucceeded();

const _kUserApiPath = 'user';
const _kPostHeaders = {
  'Content-Type': 'application/json',
};

enum RequestFeedType { restore, nextBatch }

@injectable
class HostedDiscoveryEngineService {
  final int batchSize = 2;
  final AppStatusRepository appStatusRepository;
  final HiveExplicitDocumentFeedbackRepository feedbackRepository;

  final JsonCodec _codec = const JsonCodec();
  final StreamController<ClientEventSucceeded> _onSuccess =
      StreamController<ClientEventSucceeded>();
  final StreamController<RequestFeedType> _onNextFeedBatchRequest =
      StreamController<RequestFeedType>.broadcast();
  final StreamController<Document> _onDocumentUpdate =
      StreamController<Document>();
  late final StreamSubscription<List<Document>> _feedSubscription;
  late final Uri _endPoint = Uri.parse(Env.searchApiBaseUrl)
      .replace(pathSegments: [_kUserApiPath, const Uuid().v4()]);
  final Map<Uri, bool> _observedUrls = <Uri, bool>{};
  final Map<Uri, Document> _cache = <Uri, Document>{};
  int _interactionCount = 0;
  Future<List<Document>>? _activeRequest;

  String get userId => appStatusRepository.appStatus.userId.value;

  Stream<EngineEvent> get events => Rx.merge([
        _onSuccess.stream,
        _feedEvents,
        _updateEvents,
      ]);

  Stream<EngineEvent> get _feedEvents => _onNextFeedBatchRequest.stream
      .switchMap(
        (requestFeedType) => Stream.fromFuture(_requestPersonalizedFeed())
            .map(_onFeedUpdate)
            .map(
              (it) => requestFeedType == RequestFeedType.restore
                  ? RestoreFeedSucceeded(it)
                  : NextFeedBatchRequestSucceeded(it),
            )
            .onErrorReturn(
              requestFeedType == RequestFeedType.restore
                  ? const RestoreFeedFailed(FeedFailureReason.dbError)
                  : const NextFeedBatchRequestFailed(FeedFailureReason.dbError),
            ),
      )
      .doOnData(_onFeedEvent);

  Stream<EngineEvent> get _updateEvents => _onDocumentUpdate.stream
      .map((it) => [it])
      .map(EngineEvent.documentsUpdated);

  HostedDiscoveryEngineService({
    required this.appStatusRepository,
    required this.feedbackRepository,
  }) {
    feedbackRepository.clear();
  }

  @mustCallSuper
  void close() {
    _onNextFeedBatchRequest.close();
    _feedSubscription.cancel();
  }

  Future<EngineEvent> changeUserReaction({
    required DocumentId documentId,
    required UserReaction userReaction,
  }) async {
    // as we can only support a `like` for now, ignore all other reaction types.
    if (!userReaction.supportsChangeUserReaction) return ok;

    final endPoint = _endPoint
        .replace(pathSegments: [..._endPoint.pathSegments, 'interaction']);
    final response = await http.post(
      endPoint,
      headers: _kPostHeaders,
      body: '{"document_id": "$documentId"}',
    );

    if (!response.statusCode.is2xx) {
      return EngineExceptionRaised(
        EngineExceptionReason.genericError,
        message: response.body,
        stackTrace: StackTrace.current.toString(),
      );
    }

    _onSuccess.add(ok);
    _interactionCount++;

    if (_interactionCount >= 2) _activeRequest = null;

    if (_interactionCount == 2) {
      _observedUrls.clear();
    }

    return ok;
  }

  Future<EngineEvent> requestNextFeedBatch(
      RequestFeedType requestFeedType) async {
    _onNextFeedBatchRequest.add(requestFeedType);

    return ok;
  }

  Future<EngineEvent> closeFeedDocuments(Set<DocumentId> documentIds) async {
    return ok;
  }

  List<Document> _onFeedUpdate(List<Document> documents) =>
      documents.take(batchSize).toList(growable: false);

  void _onFeedEvent(EngineEvent event) {
    if (event is NextFeedBatchRequestSucceeded) {
      for (final it in event.items) {
        _observedUrls[it.resource.url] = true;
      }
    }
  }

  Future<List<Document>> _requestPersonalizedFeed() async {
    final endPoint = _endPoint
        .replace(pathSegments: [..._endPoint.pathSegments, 'documents']);

    final req = _activeRequest ??= http
        .get(
      endPoint,
      headers: _kPostHeaders,
    )
        .then((response) {
      if (!response.statusCode.is2xx) {
        throw response.body;
      }

      final documents = _codec
          .decode(const Utf8Decoder().convert(response.bodyBytes)) as List;

      return documents
          .cast<Map<String, Object?>>()
          .map((it) => _cache.putIfAbsent(
              Uri.parse(it['link'] as String), () => it.toDocument))
          .toList(growable: false);
    });

    final documents = await req;

    return documents
        .where((it) => !_observedUrls.containsKey(it.resource.url))
        .toList(growable: false);
  }
}

extension _StatusCodeExtension on int {
  /// Returns `true` when the value is in range of `[200, 300[`.
  bool get is2xx => this == clamp(200, 299);
}

extension _UserReactionExtension on UserReaction {
  /// todo: we should soon also have support for [UserReaction.neutral] and [UserReaction.negative].
  bool get supportsChangeUserReaction => this == UserReaction.positive;
}

extension _DocumentExtension on Map<String, dynamic> {
  Document get toDocument => Document(
        documentId: DocumentId.fromString(this['id'] as String),
        stackId: StackId.nil(),
        userReaction: UserReaction.neutral,
        resource: NewsResource(
          rank: this['rank'] as int,
          title: this['title'] as String,
          image:
              this['media'] != null ? Uri.parse(this['media'] as String) : null,
          url: Uri.parse(this['link'] as String),
          topic: this['topic'] as String,
          score: this['_score'] as double?,
          language: this['language'] as String,
          country: this['country'] as String,
          datePublished: _parseDateTime(),
          snippet: this['description'] as String,
          sourceDomain: Source(this['clean_url'] as String),
        ),
      );

  DateTime _parseDateTime() {
    final value = this['published_date'] as String?;
    var date = DateTime.now();

    if (value == null) return date;

    final formatterA = DateFormat('yyyy-MM-dd hh:mm:ss'),
        formatterB = DateFormat('yyyy-MM-dd');

    try {
      date = formatterA.parse(value);
    } catch (e) {
      date = formatterB.parse(value);
    }

    return date;
  }
}
