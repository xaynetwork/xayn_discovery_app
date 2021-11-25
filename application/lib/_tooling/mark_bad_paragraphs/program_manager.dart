import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_stream.dart';
import 'package:xayn_architecture/concepts/use_case/handlers/fold.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/bing_call_endpoint_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/bing_request_builder_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/load_html_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/readability_use_case.dart';

class ProgramManager extends Cubit<ProgramState>
    with UseCaseBlocHelper<ProgramState> {
  late final UseCaseValueStream<List<String>> _apiConsumer;

  ProgramManager() : super(const ProgramState([])) {
    _init();
  }

  @override
  Future<ProgramState?> computeState() async =>
      fold(_apiConsumer).foldAll((paragraphs, errorReport) {
        if (errorReport.isNotEmpty) {
          stdout.writeln(errorReport.of(_apiConsumer)!.error);
        }

        if (paragraphs != null) {
          return ProgramState(state.pages.toList()..add(paragraphs));
        }
      });

  void handleMarkIrrelevant(String paragraph) {}

  void _init() {
    _apiConsumer = consume(
            CreateBingRequestUseCase(
              50,
              'en-US',
              'News',
            ),
            initialData: 'today')
        .transform(
      (out) => out
          .followedByEvery(InvokeBingUseCase())
          .where((it) => it.results.isNotEmpty)
          .expand((it) => it.results)
          .map((it) => it.webResource.url)
          .followedByEvery(LoadHtmlUseCase(client: Client()))
          .where((it) => it.isCompleted)
          .map(_createReadabilityConfig)
          .followedByEvery(ReadabilityUseCase())
          .followedByEvery(ExtractElementsUseCase())
          .map((it) => it.paragraphs)
          .followedByEvery(RandomizerUseCase()),
    );
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
  final List<List<String>> pages;

  const ProgramState(this.pages);
}

class RandomizerUseCase extends UseCase<List<String>, List<String>> {
  @override
  Stream<List<String>> transaction(List<String> param) {
    final random = Random();

    return Stream.value(param.toList()..sort((a, b) => random.nextInt(3) - 1));
  }
}
