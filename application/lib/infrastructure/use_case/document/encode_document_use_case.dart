import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class EncodeDocumentUseCase extends UseCase<Document, String> {
  @override
  Stream<String> transaction(Document param) async* {
    final encodedDocument = base64.encode(
      utf8.encode(
        json.encode(
          param.toJson(),
        ),
      ),
    );
    yield encodedDocument;
  }
}
