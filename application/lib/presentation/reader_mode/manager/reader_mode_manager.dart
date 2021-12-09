import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/post_process_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/reading_time_use_case.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';

@injectable
class ReaderModeManager extends Cubit<ReaderModeState>
    with UseCaseBlocHelper<ReaderModeState> {
  final PostProcessUseCase _postProcessUseCase;
  final ReadingTimeUseCase _readingTimeUseCase;

  late final UseCaseSink<ReadingTimeInput, Uri> _postProcessHandler;

  ReaderModeManager(
    this._postProcessUseCase,
    this._readingTimeUseCase,
  ) : super(ReaderModeState.empty()) {
    _initHandlers();
  }

  void handleCardData(ReadingTimeInput input) => _postProcessHandler(input);

  @override
  Future<ReaderModeState?> computeState() async =>
      fold(_postProcessHandler).foldAll((uri, errorReport) {
        if (errorReport.isNotEmpty) {}

        if (uri != null) {
          return ReaderModeState(uri: uri);
        }
      });

  void _initHandlers() {
    _postProcessHandler = pipe(_readingTimeUseCase)
        .transform((out) => out.followedBy(_postProcessUseCase));
  }
}
