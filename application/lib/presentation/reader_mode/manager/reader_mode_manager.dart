import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/error/error_object.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/extract_paragraphs_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/get_tts_preference_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/text_to_speech_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/post_process_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/manager/reader_mode_state.dart';
import 'package:xayn_readability/xayn_readability.dart';

@injectable
class ReaderModeManager extends Cubit<ReaderModeState>
    with UseCaseBlocHelper<ReaderModeState> {
  final PostProcessUseCase _postProcessUseCase;
  final TextToSpeechUseCase _textToSpeechUseCase;
  final ExtractParagraphsUseCase _extractParagraphsUseCase;
  final ListenReaderModeSettingsUseCase _listenReaderModeSettingsUseCase;
  final GetTtsPreferenceUseCase _getTtsPreferenceUseCase;

  late final UseCaseSink<PostProcessInput, Uri> _postProcessHandler =
      pipe(_postProcessUseCase);
  late final UseCaseValueStream<ReaderModeSettings> _readerModeSettingsHandler =
      consume(
    _listenReaderModeSettingsUseCase,
    initialData: none,
  );
  late final UseCaseSink<Utterance, Duration> _textToSpeechSink =
      pipe(_textToSpeechUseCase);

  ReaderModeManager(
    this._postProcessUseCase,
    this._listenReaderModeSettingsUseCase,
    this._textToSpeechUseCase,
    this._extractParagraphsUseCase,
    this._getTtsPreferenceUseCase,
    ReaderModeSettingsRepository readerModeSettingsRepository,
  ) : super(
          ReaderModeState.empty(
            readerModeSettings: readerModeSettingsRepository.settings,
          ),
        );

  void handleCardData({
    required String title,
    required ProcessHtmlResult processHtmlResult,
  }) =>
      _postProcessHandler(PostProcessInput(
        result: processHtmlResult,
        title: title,
      ));

  void handleSpeechStart({
    required String html,
    required String languageCode,
    Uri? uri,
  }) async {
    final isTtsEnabled = await _getTtsPreferenceUseCase.singleOutput(none);

    if (!isTtsEnabled) return;

    final paragraphs = await _extractParagraphsUseCase.singleOutput(html);

    _textToSpeechSink(
      Utterance(
        languageCode: languageCode,
        paragraphs: paragraphs,
        uri: uri,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _textToSpeechUseCase.stopCurrentSpeech();

    return super.close();
  }

  @override
  Future<ReaderModeState?> computeState() async => fold3(
        _postProcessHandler,
        _readerModeSettingsHandler,
        _textToSpeechSink,
      ).foldAll((
        uri,
        readerModeSettings,
        lastSpokenDuration,
        errorReport,
      ) {
        ReaderModeState newState = state;

        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_postProcessHandler) ??
              errorReport.of(_readerModeSettingsHandler) ??
              errorReport.of(_textToSpeechSink);
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
