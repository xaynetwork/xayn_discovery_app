import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/extract_paragraphs_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/text_to_speech_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/text_to_speech/manager/text_to_speech_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class TextToSpeechManager extends Cubit<TextToSpeechState>
    with UseCaseBlocHelper<TextToSpeechState> {
  final FeatureManager _featureManager;
  final TextToSpeechUseCase _textToSpeechUseCase;
  final ExtractParagraphsUseCase _extractParagraphsUseCase;
  late final UseCaseSink<Utterance, Duration> _textToSpeechSink =
      pipe(_textToSpeechUseCase);

  TextToSpeechManager(
    this._textToSpeechUseCase,
    this._extractParagraphsUseCase,
    this._featureManager,
  ) : super(TextToSpeechState.silent());

  void handleStart({
    required String html,
    required String languageCode,
    Uri? uri,
  }) async {
    final isFeatureEnabled = _featureManager.isEnabled(Feature.textToSpeech);

    if (!isFeatureEnabled) return;

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
  Future<TextToSpeechState?> computeState() async => fold(
        _textToSpeechSink,
      ).foldAll((lastSpokenDuration, errorReport) {
        if (errorReport.exists(_textToSpeechSink)) {
          logger.e(errorReport.of(_textToSpeechSink));
        }

        if (lastSpokenDuration != null) {
          return TextToSpeechState.speaking(
            totalSpokenDuration: state.totalSpokenDuration + lastSpokenDuration,
            lastSpokenDuration: lastSpokenDuration,
          );
        }
      });
}
