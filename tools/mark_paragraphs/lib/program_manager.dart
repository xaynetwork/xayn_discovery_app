import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:mark_paragraphs/auth_use_case.dart';
import 'package:mark_paragraphs/submit_paragraph_use_case.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/bing_call_endpoint_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/bing_request_builder_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';

class ProgramManager extends Cubit<ProgramState>
    with UseCaseBlocHelper<ProgramState> {
  late final UseCaseValueStream<List<String>> _apiConsumer;
  late final UseCaseSink<String, Map<String, String>> _paragraphHandler;

  ProgramManager() : super(const ProgramState({}, {})) {
    _init();
  }

  @override
  Future<ProgramState?> computeState() async => fold2(
        _apiConsumer,
        _paragraphHandler,
      ).foldAll((
        paragraphs,
        badParagraph,
        errorReport,
      ) {
        if (errorReport.isNotEmpty) {
          final reportA = errorReport.of(_apiConsumer);
          final reportB = errorReport.of(_paragraphHandler);

          if (reportA != null) {
            stdout.writeln(reportA.error);
          }

          if (reportB != null) {
            stdout.writeln(reportB.error);
          }
        }

        final nextParagraphs = state.paragraphs.toSet();
        final nextBadParagraphs = state.badParagraphs.toSet();

        if (paragraphs != null) {
          nextParagraphs.addAll(paragraphs);
        }

        if (badParagraph != null) {
          nextBadParagraphs.add(badParagraph['text']!);
        }

        return ProgramState(nextParagraphs, nextBadParagraphs);
      });

  void handleMarkIrrelevant(String paragraph) => _paragraphHandler(paragraph);

  void _init() {
    final random = Random();
    final index = random.nextInt(words.length);
    final word = words[index];

    _apiConsumer = consume(
      CreateBingRequestUseCase(
        50,
        'en-US',
        'News',
      ),
      initialData: word,
    ).transform(
      (out) => out
          .followedBy(InvokeBingUseCase())
          .where((it) => it.results.isNotEmpty)
          .expand((it) => it.results)
          .map((it) => it.webResource.url)
          .followedBy(LoadHtmlUseCase(client: Client()))
          .where((it) => it.isCompleted)
          .map(_createReadabilityConfig)
          .followedBy(ReadabilityUseCase())
          .followedBy(ExtractElementsUseCase())
          .map((it) => it.paragraphs)
          .followedBy(RandomizerUseCase()),
    );

    _paragraphHandler = pipe(AuthUseCase())
        .transform((out) => out.followedBy(SubmitParagraphUseCase()));
  }

  ReadabilityConfig _createReadabilityConfig(Progress progress) =>
      ReadabilityConfig(
        uri: progress.uri,
        html: progress.html,
        disableJsonLd: true,
        classesToPreserve: const [],
      );
}

class ProgramState {
  final Set<String> paragraphs;
  final Set<String> badParagraphs;

  const ProgramState(
    this.paragraphs,
    this.badParagraphs,
  );
}

class RandomizerUseCase extends UseCase<List<String>, List<String>> {
  @override
  Stream<List<String>> transaction(List<String> param) =>
      Stream.value(param.toList()..sort((a, b) => a.compareTo(b)));
}

const words = [
  'today',
  'politics',
  'football',
  'tennis',
  'golf',
  'europe',
  'Germany',
  'war',
  'covid',
];
