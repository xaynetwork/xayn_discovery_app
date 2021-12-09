import 'package:html/dom.dart' as dom;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
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
class ReadingTimeUseCase extends UseCase<ReadingTimeInput, ProcessHtmlResult> {
  ReadingTimeUseCase();

  @override
  Stream<ProcessHtmlResult> transaction(ReadingTimeInput param) async* {
    final readingSpeed = kReadingSpeed[param.lang] ?? kDefaultSpeed;
    final size = param.processHtmlResult.textSize;
    final slow = (size / readingSpeed.charactersPerMinuteLow).ceil();
    final fast = (size / readingSpeed.charactersPerMinuteHigh).ceil();
    late final ReadingTimeOutput output;

    if (slow == fast) {
      switch (slow) {
        case 1:
          output = ReadingTimeOutput(
              processHtmlResult: param.processHtmlResult,
              timeToRead: '1 ${param.singleUnit}');
          break;
        default:
          output = ReadingTimeOutput(
              processHtmlResult: param.processHtmlResult,
              timeToRead: '$slow ${param.pluralUnit}');
      }
    } else {
      output = ReadingTimeOutput(
          processHtmlResult: param.processHtmlResult,
          timeToRead: '$fast - $slow ${param.pluralUnit}');
    }

    yield await compute(_injectMetadataIntoProcessedHtml, output);
  }
}

ProcessHtmlResult _injectMetadataIntoProcessedHtml(ReadingTimeOutput output) {
  final document =
      dom.Document.html(output.processHtmlResult.contents ?? '''<div></div>''');
  final byline = output.processHtmlResult.metadata?.byline;
  var element = document.querySelector('article') ??
      document.querySelector('div,section') ??
      document.body!.children.first;

  while (element.children.length == 1) {
    element = element.children.first;
  }

  document.querySelectorAll('h1,h2').forEach((element) {
    element.replaceWith(dom.Element.tag('h3')..innerHtml = element.innerHtml);
  });

  final parts = [
    if (output.processHtmlResult.title != null)
      '''
          <p style="font-size:150%">
            <h2>${output.processHtmlResult.title}</h2>
          </p>
        ''',
    if (byline != null)
      '''
          <p>$byline</p>
        ''',
    '''
        <p style="color:#666">
          <i>${output.timeToRead}</i>
        </p>
      ''',
  ];

  element.innerHtml = '${parts.join('\r\n')}${element.innerHtml}';

  return output.processHtmlResult.withOtherContent(element.outerHtml);
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
class ReadingTimeOutput {
  final ProcessHtmlResult processHtmlResult;
  final String timeToRead;

  const ReadingTimeOutput({
    required this.processHtmlResult,
    required this.timeToRead,
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
