import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@singleton
class ExplicitDocumentFeedbackMapper
    extends BaseDbEntityMapper<ExplicitDocumentFeedback> {
  @override
  ExplicitDocumentFeedback? fromMap(Map? map) {
    if (map == null) return null;

    final String id = map[ExplicitDocumentFeedbackMapperFields.id] ??
        throwMapperException() as String;
    final int userReaction =
        map[ExplicitDocumentFeedbackMapperFields.userReaction] ??
            throwMapperException() as int;

    return ExplicitDocumentFeedback(
      id: UniqueId.fromTrustedString(id),
      userReaction: userReaction == -1
          ? UserReaction.negative
          : userReaction == 0
              ? UserReaction.neutral
              : UserReaction.positive,
    );
  }

  @override
  DbEntityMap toMap(ExplicitDocumentFeedback entity) => {
        ExplicitDocumentFeedbackMapperFields.id: entity.id.value,
        ExplicitDocumentFeedbackMapperFields.userReaction:
            entity.userReaction.isIrrelevant
                ? -1
                : entity.userReaction.isNeutral
                    ? 0
                    : 1,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'CollectionMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class ExplicitDocumentFeedbackMapperFields {
  static const int id = 0;
  static const int userReaction = 1;
}
