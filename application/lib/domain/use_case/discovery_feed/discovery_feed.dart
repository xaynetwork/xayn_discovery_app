import 'package:flutter/foundation.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// [UseCase] interface for abstracting createHttpRequest
typedef CreateHttpRequestUseCase = UseCase<String, Uri>;

/// [UseCase] interface for abstracting invokeApiEndpoint
typedef InvokeApiEndpointUseCase = UseCase<Uri, ApiEndpointResponse>;

/// The return type of [InvokeApiEndpointUseCase]
class ApiEndpointResponse {
  final List<Document> results;
  final bool isComplete;

  const ApiEndpointResponse.incomplete()
      : results = const [],
        isComplete = false;

  const ApiEndpointResponse.complete(this.results) : isComplete = true;
}

/// Error which can be emitted during [InvokeApiEndpointUseCase]
@immutable
class ApiEndpointError extends Error {
  final int statusCode;
  final String body;

  ApiEndpointError({
    required this.statusCode,
    required this.body,
  });
}
