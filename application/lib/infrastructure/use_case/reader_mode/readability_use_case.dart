import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_readability/xayn_readability.dart';

/// A [UseCase] which invokes xayn_readability.
/// The html that is being provided by [ReadabilityConfig] as input,
/// is processed into reader mode html, and returned as output with [ProcessHtmlResult].
@injectable
class ReadabilityUseCase<T>
    extends UseCase<ReadabilityConfig, ProcessHtmlResult> {
  ReadabilityUseCase();

  @override
  Stream<ProcessHtmlResult> transaction(ReadabilityConfig param) async* {
    final baseUri = param.uri.replace(
        pathSegments: const [],
        queryParameters: const <String, dynamic>{},
        fragment: null);

    yield await compute(
        makeReadable,
        MakeReadablePayload(
          contents: param.html,
          options: ParserOptions(
            disableJsonLd: param.disableJsonLd,
            classesToPreserve: param.classesToPreserve,
            baseUri: baseUri,
          ),
        ));
  }
}

/// The input for [ReadabilityUseCase].
/// This class represents configuration options for the readability
/// operation which will be executed within the [ReadabilityUseCase].
class ReadabilityConfig {
  final String html;
  final bool disableJsonLd;
  final List<String> classesToPreserve;
  final Uri uri;

  const ReadabilityConfig({
    required this.html,
    required this.disableJsonLd,
    required this.classesToPreserve,
    required this.uri,
  });
}
