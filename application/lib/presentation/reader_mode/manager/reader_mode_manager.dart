import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/post_process_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class ReaderModeManager extends Cubit<ReaderModeState>
    with UseCaseBlocHelper<ReaderModeState> {
  final PostProcessUseCase _postProcessUseCase;

  late final UseCaseSink<PostProcessInput, Uri> _postProcessHandler;

  late final ListenReaderModeSettingsUseCase _listenReaderModeSettingsUseCase;
  late final UseCaseValueStream<ReaderModeSettings> _readerModeSettingsHandler;

  ReaderModeManager(
    this._postProcessUseCase,
    this._listenReaderModeSettingsUseCase,
    ReaderModeSettingsRepository readerModeSettingsRepository,
  ) : super(ReaderModeState.empty(
          readerModeSettings: readerModeSettingsRepository.settings,
        )) {
    _initHandlers();
  }

  void _initHandlers() {
    _postProcessHandler = pipe(_postProcessUseCase);
    _readerModeSettingsHandler = consume(
      _listenReaderModeSettingsUseCase,
      initialData: none,
    );
  }

  void handleCardData({
    required String title,
    required ProcessHtmlResult processHtmlResult,
  }) =>
      _postProcessHandler(PostProcessInput(
        result: processHtmlResult,
        title: title,
      ));

  @override
  Future<ReaderModeState?> computeState() async => fold2(
        _postProcessHandler,
        _readerModeSettingsHandler,
      ).foldAll((uri, readerModeSettings, errorReport) {
        ReaderModeState newState = state;

        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_postProcessHandler) ??
              errorReport.of(_readerModeSettingsHandler);
          newState = state.copyWith(
            error: ErrorObject(report!.error),
          );
        }

        if (readerModeSettings != null) {
          return newState.copyWith(
            readerModeSettings: readerModeSettings,
            uri: uri,
          );
        }

        if (uri != null) {
          return newState.copyWith(uri: uri);
        }
      });
}
