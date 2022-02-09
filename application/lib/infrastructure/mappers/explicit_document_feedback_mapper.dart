import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@singleton
class ExplicitDocumentFeedbackMapper
    extends BaseDbEntityMapper<ExplicitDocumentFeedback> {
  @override
  ExplicitDocumentFeedback? fromMap(Map? map) {
    if (map == null) return null;

    final String id = map[ExplicitDocumentFeedbackMapperFields.id] ??
        throwMapperException() as String;
    final int feedback = map[ExplicitDocumentFeedbackMapperFields.feedback] ??
        throwMapperException() as int;

    return ExplicitDocumentFeedback(
      id: UniqueId.fromTrustedString(id),
      feedback: feedback == -1
          ? DocumentFeedback.negative
          : feedback == 0
              ? DocumentFeedback.neutral
              : DocumentFeedback.positive,
    );
  }

  @override
  DbEntityMap toMap(ExplicitDocumentFeedback entity) => {
        ExplicitDocumentFeedbackMapperFields.id: entity.id.value,
        ExplicitDocumentFeedbackMapperFields.feedback:
            entity.feedback == DocumentFeedback.negative
                ? -1
                : entity.feedback == DocumentFeedback.neutral
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
  static const int feedback = 1;
}
