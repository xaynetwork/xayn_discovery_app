import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/post_process_use_case.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';
import 'package:xayn_readability/xayn_readability.dart';

class ReaderModeManager extends Cubit<ReaderModeState>
    with UseCaseBlocHelper<ReaderModeState> {
  final PostProcessUseCase _postProcessUseCase;

  late final UseCaseSink<CardData, ProcessHtmlResult> _postProcessHandler;

  ReaderModeManager(this._postProcessUseCase) : super(ReaderModeState.empty()) {
    _initHandlers();
  }

  void handleHtmlResult({
    required String title,
    required String snippet,
    required Uri imageUri,
    required ProcessHtmlResult processHtmlResult,
  }) =>
      _postProcessHandler(CardData(
        title: title.trim(),
        snippet: snippet.trim(),
        imageUri: imageUri,
        processHtmlResult: processHtmlResult,
      ));

  @override
  Future<ReaderModeState> computeState() async =>
      fold(_postProcessHandler).foldAll((a, errorReport) {});

  void _initHandlers() {
    _postProcessHandler = pipe(_postProcessUseCase);
  }
}
