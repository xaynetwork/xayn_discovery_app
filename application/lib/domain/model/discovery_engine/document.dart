import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document_id.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/web_resource.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
class Document with _$Document implements xayn.Document {
  const Document._();

  const factory Document({
    required DocumentId documentId,
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
  // TODO: implement isNeutral
  bool get isNeutral => throw UnimplementedError();

  @override
  // TODO: implement isNotRelevant
  bool get isNotRelevant => throw UnimplementedError();

  @override
  // TODO: implement isRelevant
  bool get isRelevant => throw UnimplementedError();

  @override
  // TODO: implement wasOpened
  bool get wasOpened => throw UnimplementedError();
}
