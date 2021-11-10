import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

/// The Duration that is used to debounce incoming changes
@visibleForTesting
const Duration kScrollUpdateUseCaseDebounceTime = Duration(milliseconds: 600);

/// Mock implementation,
/// This will be deprecated once the real discovery engine is available.
///
/// An implementation of [CreateHttpRequestUseCase] which creates a http
/// request for usage with the Bing news api.
@Injectable(as: CreateHttpRequestUseCase)
class CreateBingRequestUseCase extends CreateHttpRequestUseCase {
  CreateBingRequestUseCase();

  @override
  Stream<Uri> transaction(String param) async* {
    yield Uri.https(Env.searchApiBaseUrl, '_d/search', {
      'q': param.trim(),
      'count': '5',
      'mkt': 'en-US',
      'responseFilter': 'News',
    });
  }

  @override
  Stream<String> transform(Stream<String> incoming) =>
      incoming.debounceTime(kScrollUpdateUseCaseDebounceTime);
}
