import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/document_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';

@injectable
class GetDocumentUseCase extends UseCase<UniqueId, Document> {
  final DocumentRepository _documentRepository;

  GetDocumentUseCase(this._documentRepository);

  @override
  Stream<Document> transaction(UniqueId param) async* {
    final wrapper = _documentRepository.getById(param);
    if (wrapper == null) {
      throw BookmarkUseCaseError.tryingToGetNotExistingBookmark;
    }
    yield wrapper.document;
  }
}

enum DocumentUseCaseError {
  tryingToGetNotExistingDocument,
}
