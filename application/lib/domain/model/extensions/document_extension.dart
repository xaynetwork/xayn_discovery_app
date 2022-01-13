import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

extension DocumentExtension on Document {
  bool get isNeutral => feedback == DocumentFeedback.neutral;

  bool get isRelevant => feedback == DocumentFeedback.positive;

  bool get isIrrelevant => feedback == DocumentFeedback.negative;

  UniqueId get documentUniqueId => documentId.uniqueId;
}

extension DocumentIdUtils on DocumentId {
  UniqueId get uniqueId => UniqueId.fromTrustedString(toString());
}
