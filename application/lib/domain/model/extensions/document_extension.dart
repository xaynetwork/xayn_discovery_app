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

extension DocumentFeedbackExtension on DocumentFeedback {
  String stringify() {
    switch (this) {
      case DocumentFeedback.neutral:
        return 'neutral';
      case DocumentFeedback.negative:
        return 'negative';
      case DocumentFeedback.positive:
        return 'positive';
    }
  }
}

extension DocumentViewModeExtension on DocumentViewMode {
  String stringify() {
    switch (this) {
      case DocumentViewMode.reader:
        return 'reader';
      case DocumentViewMode.story:
        return 'story';
      case DocumentViewMode.web:
        return 'web';
    }
  }
}
