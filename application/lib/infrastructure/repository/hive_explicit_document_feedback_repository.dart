import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/domain/repository/explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/explicit_document_feedback_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [AppSettings] repository implementation.
@singleton
class HiveExplicitDocumentFeedbackRepository
    extends HiveRepository<ExplicitDocumentFeedback>
    implements ExplicitDocumentFeedbackRepository {
  final ExplicitDocumentFeedbackMapper _mapper;
  Box<Record>? _box;

  HiveExplicitDocumentFeedbackRepository(this._mapper);

  @visibleForTesting
  HiveExplicitDocumentFeedbackRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<ExplicitDocumentFeedback> get mapper => _mapper;

  @override
  Box<Record> get box =>
      _box ??= Hive.safeBox<Record>(BoxNames.explicitDocumentFeedback);
}
