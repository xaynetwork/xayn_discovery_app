import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/model/legacy/user_reaction.dart';

part 'explicit_document_feedback.freezed.dart';

@freezed
class ExplicitDocumentFeedback extends DbEntity
    with _$ExplicitDocumentFeedback {
  factory ExplicitDocumentFeedback({
    required UniqueId id,
    @Default(UserReaction.neutral) UserReaction userReaction,
  }) = _ExplicitDocumentFeedback;
}
