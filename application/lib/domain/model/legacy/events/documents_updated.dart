import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';

class DocumentsUpdated implements EngineEvent {
  final List<Document> items;

  const DocumentsUpdated(this.items);
}
