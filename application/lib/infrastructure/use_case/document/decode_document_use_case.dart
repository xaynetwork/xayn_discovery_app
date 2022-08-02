import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class DecodeDocumentUseCase extends UseCase<String, Document> {
  @override
  Stream<Document> transaction(String param) async* {
    final decodedDocument = Document.fromJson(
      json.decode(
        utf8.decode(
          base64.decode(param),
        ),
      ),
    );
    yield decodedDocument;
  }
}
