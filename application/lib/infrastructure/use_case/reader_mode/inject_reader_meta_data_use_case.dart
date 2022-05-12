import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/remote_content/processed_document.dart';
import 'package:xayn_readability/xayn_readability.dart';

const Speed kDefaultSpeed = Speed(cpm: 987, variance: 118);
const Map<String, Speed> kReadingSpeed = {
  'en': kDefaultSpeed,
  'ar': Speed(cpm: 612, variance: 88),
  'de': Speed(cpm: 920, variance: 86),
  'es': Speed(cpm: 1025, variance: 127),
  'fi': Speed(cpm: 1078, variance: 121),
  'fr': Speed(cpm: 998, variance: 126),
  'he': Speed(cpm: 833, variance: 130),
  'it': Speed(cpm: 950, variance: 140),
  'jw': Speed(cpm: 357, variance: 56),
  'nl': Speed(cpm: 978, variance: 143),
  'pl': Speed(cpm: 916, variance: 126),
  'pt': Speed(cpm: 913, variance: 145),
  'ru': Speed(cpm: 986, variance: 175),
  'sk': Speed(cpm: 885, variance: 145),
  'sv': Speed(cpm: 917, variance: 156),
  'tr': Speed(cpm: 1054, variance: 156),
  'zh': Speed(cpm: 255, variance: 29),
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
class Speed {
  final int cpm, variance;
  final int charactersPerMinuteLow, charactersPerMinuteHigh;

  const Speed({
    required this.cpm,
    required this.variance,
  })  : charactersPerMinuteLow = cpm - variance,
        charactersPerMinuteHigh = cpm + variance;
}
