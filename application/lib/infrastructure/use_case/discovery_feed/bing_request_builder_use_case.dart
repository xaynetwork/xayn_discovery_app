import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';

@visibleForTesting
const Duration kScrollUpdateUseCaseDebounceTime = Duration(milliseconds: 600);

@Injectable(as: CreateHttpRequestUseCase)
class CreateBingRequestUseCase<T> extends CreateHttpRequestUseCase {
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
