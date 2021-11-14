import 'dart:math';

import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/document.dart';
import 'package:injectable/injectable.dart';

/// These are random keywords, real keywords are to be provided by the
/// real discovery engine.
const List<String> randomKeywords = [
  'german',
  'french',
  'english',
  'american',
  'hollywood',
  'music',
  'broadway',
  'football',
  'tennis',
  'covid',
  'trump',
  'merkel',
  'cars',
  'sports',
  'market',
  'economy',
  'financial',
];

@injectable
class RandomWordUseCase extends UseCase<List<Document>, String> {
  final Random rnd = Random();
  late String nextFakeKeyword;

  RandomWordUseCase() {
    _initGeneral();
  }

  void _initGeneral() {
    nextFakeKeyword = randomKeywords[rnd.nextInt(randomKeywords.length)];
  }

  @override
  Stream<String> transaction(List<Document> param) async* {
    nextFakeKeyword = _fakeNextKeywork(param);
    yield nextFakeKeyword;
  }

  /// selects a random word from the combined set of [Result.description]s.
  String _fakeNextKeywork(List<Document> nextResults) {
    if (nextResults.isEmpty) {
      return randomKeywords[rnd.nextInt(randomKeywords.length)];
    }

    final words = nextResults
        .map((it) => it.webResource.snippet)
        .join(' ')
        .split(RegExp(r'[\s]+'))
        .where((it) => it.length >= 5)
        .toList(growable: false);

    if (words.isEmpty) {
      return randomKeywords[rnd.nextInt(randomKeywords.length)];
    }

    return words[rnd.nextInt(words.length)];
  }
}
