import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

extension DocumentExtension on Document {
  UniqueId get documentUniqueId => documentId.uniqueId;
}

extension DocumentIdUtils on DocumentId {
  UniqueId get uniqueId => UniqueId.fromTrustedString(toString());
}

extension DocumentFeedbackExtension on DocumentFeedback {
  bool get isNeutral => this == DocumentFeedback.neutral;

  bool get isRelevant => this == DocumentFeedback.positive;

  bool get isIrrelevant => this == DocumentFeedback.negative;
}
