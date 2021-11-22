import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document_id.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;

part 'document.freezed.dart';
part 'document.g.dart';

/// Mock implementation which implements [xayn.Document].
/// This will be deprecated once the real discovery engine is available.
@freezed
class Document with _$Document implements xayn.Document {
  const Document._();

  const factory Document({
    required DocumentId documentId,
    required DocumentFeedback documentFeedback,
    required WebResource webResource,
    required int nonPersonalizedRank,
    required int personalizedRank,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

  @override
  int currentRank(bool isPersonalisationOn) {
    // TODO: implement currentRank
    throw UnimplementedError();
  }

  @override
  bool get isNeutral => documentFeedback == DocumentFeedback.neutral;

  @override
  bool get isNotRelevant => documentFeedback == DocumentFeedback.negative;

  @override
  bool get isRelevant => documentFeedback == DocumentFeedback.positive;

  @override
  // TODO: implement wasOpened
  bool get wasOpened => throw UnimplementedError();
}

/// Mock implementation which implements [xayn.DocumentFeedback].
enum DocumentFeedback {
  neutral,
  positive,
  negative,
}
