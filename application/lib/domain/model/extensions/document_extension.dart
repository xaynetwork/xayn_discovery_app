import 'package:xayn_discovery_engine/discovery_engine.dart';

extension DocumentExtension on Document {
  bool get isNeutral => feedback == DocumentFeedback.neutral;
  bool get isRelevant => feedback == DocumentFeedback.positive;
  bool get isIrrelevant => feedback == DocumentFeedback.negative;
}
