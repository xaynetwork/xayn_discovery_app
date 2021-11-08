import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';

typedef CreateHttpRequestUseCase = UseCase<String, Uri>;
typedef InvokeApiEndpointUseCase = UseCase<Uri, ApiEndpointResponse>;

class ApiEndpointResponse {
  final List<Document> results;
  final bool isComplete;

  const ApiEndpointResponse.incomplete()
      : results = const [],
        isComplete = false;

  const ApiEndpointResponse.complete(this.results) : isComplete = true;
}

class ApiEndpointError extends Error {
  final int statusCode;
  final String body;

  ApiEndpointError({
    required this.statusCode,
    required this.body,
  });
}
