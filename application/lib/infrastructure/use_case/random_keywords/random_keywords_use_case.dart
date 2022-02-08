import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

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
class RandomKeyWordsUseCase extends UseCase<List<Document>, String> {
  final Random _rnd = Random();
  late String nextFakeKeyword;

  RandomKeyWordsUseCase() {
    _initGeneral();
  }

  void _initGeneral() {
    nextFakeKeyword = randomKeywords[_rnd.nextInt(randomKeywords.length)];
  }

  @override
  Stream<String> transaction(List<Document> param) async* {
    nextFakeKeyword = _fakeNextKeywork(param);
    yield nextFakeKeyword;
  }

  /// selects a random word from the combined set of [Result.description]s.
  String _fakeNextKeywork(List<Document> nextResults) {
    if (nextResults.isEmpty) {
      return randomKeywords[_rnd.nextInt(randomKeywords.length)];
    }

    final words = nextResults
        .map((it) => it.resource.snippet)
        .join(' ')
        .split(RegExp(r'[\s]+'))
        .where((it) => it.length >= 5)
        .toList(growable: false);

    if (words.isEmpty) {
      return randomKeywords[_rnd.nextInt(randomKeywords.length)];
    }

    return words[_rnd.nextInt(words.length)];
  }
}
