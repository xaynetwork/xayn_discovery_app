import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html/dom.dart' as dom;
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_feed/text_to_speech_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/text_to_speech/manager/text_to_speech_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class TextToSpeechManager extends Cubit<TextToSpeechState>
    with UseCaseBlocHelper<TextToSpeechState> {
  final FeatureManager _featureManager;
  final TextToSpeechUseCase _textToSpeechUseCase;
  late final UseCaseSink<Utterance, Duration> _textToSpeechSink =
      pipe(_textToSpeechUseCase);

  TextToSpeechManager(
    this._textToSpeechUseCase,
    this._featureManager,
  ) : super(TextToSpeechState.silent());

  static List<String> extractParagraphs(final String contents) {
    final element = dom.DocumentFragment.html(contents);

    return element
        .querySelectorAll('p')
        .map((it) => it.text)
        .toList(growable: false);
  }

  void handleStart({
    required List<String> paragraphs,
    required String languageCode,
    Uri? uri,
  }) =>
      _featureManager.isEnabled(Feature.textToSpeech)
          ? _textToSpeechSink(
              Utterance(
                languageCode: languageCode,
                paragraphs: paragraphs,
                uri: uri,
              ),
            )
          : null;

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
