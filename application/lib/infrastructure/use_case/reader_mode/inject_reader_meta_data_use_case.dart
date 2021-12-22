import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_readability/xayn_readability.dart';

const _Speed kDefaultSpeed = _Speed(cpm: 987, variance: 118);
const Map<String, _Speed> kReadingSpeed = {
  'en': kDefaultSpeed,
  'ar': _Speed(cpm: 612, variance: 88),
  'de': _Speed(cpm: 920, variance: 86),
  'es': _Speed(cpm: 1025, variance: 127),
  'fi': _Speed(cpm: 1078, variance: 121),
  'fr': _Speed(cpm: 998, variance: 126),
  'he': _Speed(cpm: 833, variance: 130),
  'it': _Speed(cpm: 950, variance: 140),
  'jw': _Speed(cpm: 357, variance: 56),
  'nl': _Speed(cpm: 978, variance: 143),
  'pl': _Speed(cpm: 916, variance: 126),
  'pt': _Speed(cpm: 913, variance: 145),
  'ru': _Speed(cpm: 986, variance: 175),
  'sk': _Speed(cpm: 885, variance: 145),
  'sv': _Speed(cpm: 917, variance: 156),
  'tr': _Speed(cpm: 1054, variance: 156),
  'zh': _Speed(cpm: 255, variance: 29),
};

@singleton
class InjectReaderMetaDataUseCase
    extends UseCase<ReadingTimeInput, ProcessedDocument> {
  InjectReaderMetaDataUseCase();

  @override
  Stream<ProcessedDocument> transaction(ReadingTimeInput param) async* {
    final readingSpeed = kReadingSpeed[param.lang] ?? kDefaultSpeed;
    final size = param.processHtmlResult.textSize;
    final slow = (size / readingSpeed.charactersPerMinuteLow).ceil();
    final fast = (size / readingSpeed.charactersPerMinuteHigh).ceil();
    late final ProcessedDocument output;

    if (slow == fast) {
      switch (slow) {
        case 1:
          output = ProcessedDocument(
              processHtmlResult: param.processHtmlResult,
              timeToRead: '1 ${param.singleUnit}');
          break;
        default:
          output = ProcessedDocument(
              processHtmlResult: param.processHtmlResult,
              timeToRead: '$slow ${param.pluralUnit}');
      }
    } else {
      output = ProcessedDocument(
          processHtmlResult: param.processHtmlResult,
          timeToRead: '$fast - $slow ${param.pluralUnit}');
    }

    yield output;
  }
}

@immutable
class ReadingTimeInput {
  final ProcessHtmlResult processHtmlResult;
  final String lang;
  final String singleUnit;
  final String pluralUnit;

  const ReadingTimeInput({
    required this.processHtmlResult,
    required this.lang,
    required this.singleUnit,
    required this.pluralUnit,
  });
}

@immutable
class _Speed {
  final int cpm, variance;
  final int charactersPerMinuteLow, charactersPerMinuteHigh;

  const _Speed({
    required this.cpm,
    required this.variance,
  })  : charactersPerMinuteLow = cpm - variance,
        charactersPerMinuteHigh = cpm + variance;
}
