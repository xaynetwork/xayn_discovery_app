import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/text_to_speech_use_case.dart';
import 'package:xayn_discovery_app/presentation/text_to_speech/manager/text_to_speech_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class TextToSpeechManager extends Cubit<TextToSpeechState>
    with UseCaseBlocHelper<TextToSpeechState> {
  final TextToSpeechUseCase _textToSpeechUseCase;
  late final UseCaseSink<Utterance, Duration> _textToSpeechSink =
      pipe(_textToSpeechUseCase);

  TextToSpeechManager(this._textToSpeechUseCase)
      : super(TextToSpeechState.silent());

  void handleStart({
    required List<String> paragraphs,
    Uri? uri,
  }) =>
      _textToSpeechSink(Utterance(
        uri: uri,
        paragraphs: paragraphs,
      ));

  @override
  Future<void> close() {
    _textToSpeechUseCase.stopCurrentSpeech();

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
