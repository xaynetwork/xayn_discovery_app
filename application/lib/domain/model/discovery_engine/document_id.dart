import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;

part 'document_id.freezed.dart';
part 'document_id.g.dart';

/// Mock implementation which implements [xayn.DocumentId].
/// This will be deprecated once the real discovery engine is available.
@freezed
class DocumentId with _$DocumentId implements xayn.DocumentId {
  const DocumentId._();

  const factory DocumentId({
    required String key,
  }) = _DocumentId;

  factory DocumentId.fromJson(Map<String, dynamic> json) =>
      _$DocumentIdFromJson(json);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool? get stringify => throw UnimplementedError();

  @override
  // TODO: implement value
  UnmodifiableUint8ListView get value => throw UnimplementedError();
}
