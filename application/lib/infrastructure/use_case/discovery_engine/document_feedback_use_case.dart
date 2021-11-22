import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document_id.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/base_events.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/document_events.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/system_events.dart';

const Duration kDebounceDuration = Duration(milliseconds: 400);

/// Mock implementation,
/// This will be deprecated once the real discovery engine is available.
///
/// A [UseCase] which sends a like event of a [DocumentId] to the [DiscoveryEngineManager].

@Injectable()
class DocumentFeedbackUseCase
    extends UseCase<DocumentFeedbackChanged, EngineEvent> {
  final DiscoveryEngineManager _discoveryApi;

  DocumentFeedbackUseCase(this._discoveryApi);

  @override
  Stream<EngineEvent> transaction(DocumentFeedbackChanged param) async* {
    _discoveryApi.onClientEvent.add(
      DocumentFeedbackChanged(param.documentId, param.feedback),
    );

    yield const ClientEventSucceeded();
  }

  @override
  Stream<DocumentFeedbackChanged> transform(
          Stream<DocumentFeedbackChanged> incoming) =>
      incoming.distinct().debounceTime(kDebounceDuration);
}
