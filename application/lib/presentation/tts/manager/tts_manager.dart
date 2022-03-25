import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/extract_paragraphs_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/tts/text_to_speech_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/tts/manager/tts_state.dart';

/// Singleton because TTS is a native bridge, we basically communicate with a
/// single-instance TTS there.
@singleton
class TtsManager extends Cubit<TtsState> with UseCaseBlocHelper<TtsState> {
  final TextToSpeechUseCase _textToSpeechUseCase;
  final ExtractParagraphsUseCase _extractParagraphsUseCase;
  final FeatureManager _featureManager;

  late final UseCaseSink<Utterance, Duration> _textToSpeechSink =
      pipe(_textToSpeechUseCase);

  TtsManager(
    this._textToSpeechUseCase,
    this._extractParagraphsUseCase,
    this._featureManager,
  ) : super(TtsState.initial());

  @override
  Future<void> close() async {
    await _textToSpeechUseCase.stopCurrentSpeech();

    return super.close();
  }

  void start({
    required String html,
    required String languageCode,
    Uri? uri,
  }) async {
    if (!_featureManager.isTtsEnabled) return;

    final paragraphs = await _extractParagraphsUseCase.singleOutput(html);

    await stop();

    _textToSpeechSink(
      Utterance(
        languageCode: languageCode,
        paragraphs: paragraphs,
        uri: uri,
      ),
    );
  }

  Future<void> stop() => _textToSpeechUseCase.stopCurrentSpeech();

  @override
  Future<TtsState?> computeState() async => fold(_textToSpeechSink)
      .foldAll((duration, _) => TtsState(duration: duration ?? Duration.zero));
}
