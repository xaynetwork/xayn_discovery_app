import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_background_color_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_font_size_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_font_style_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_background_color_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_size_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_style_use_case.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_state.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

@injectable
class EditReaderModeSettingsManager extends Cubit<EditReaderModeSettingsState>
    with UseCaseBlocHelper<EditReaderModeSettingsState> {
  final SaveReaderModeBackgroundColorUseCase
      _saveReaderModeBackgroundColorUseCase;
  final SaveReaderModeFontSizeUseCase _saveReaderModeFontSizeUseCase;
  final SaveReaderModeFontStyleUseCase _saveReaderModeFontStyleUseCase;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;

  late final UseCaseSink<ReaderModeBackgroundColor, ReaderModeBackgroundColor>
      _saveBackgroundColorHandler = pipe(_saveReaderModeBackgroundColorUseCase);
  late final UseCaseSink<ReaderModeFontSize, ReaderModeFontSize>
      _saveFontSizeHandler = pipe(_saveReaderModeFontSizeUseCase);
  late final UseCaseSink<ReaderModeFontStyle, ReaderModeFontStyle>
      _saveFontStyleHandler = pipe(_saveReaderModeFontStyleUseCase);

  EditReaderModeSettingsManager(
    this._saveReaderModeFontSizeUseCase,
    this._saveReaderModeBackgroundColorUseCase,
    this._saveReaderModeFontStyleUseCase,
    this._sendAnalyticsUseCase,
    ReaderModeSettingsRepository readerModeSettingsRepository,
  ) : super(EditReaderModeSettingsState(
          readerModeFontStyle: readerModeSettingsRepository.settings.fontStyle,
          readerModeFontSize: readerModeSettingsRepository.settings.fontSize,
          readerModeBackgroundColor:
              readerModeSettingsRepository.settings.backgroundColor,
        ));

  void onDarkBackgroundColorPressed(ReaderModeBackgroundDarkColor darkColor) {
    final backgroundColor = state.readerModeBackgroundColor.copyWith(
      dark: darkColor,
    );
    _saveBackgroundColorHandler(backgroundColor);
    _sendAnalyticsUseCase(
      ReaderModeBackgroundColorChanged(backgroundColor: backgroundColor),
    );
  }

  void onLightBackgroundColorPressed(
      ReaderModeBackgroundLightColor lightColor) {
    final backgroundColor = state.readerModeBackgroundColor.copyWith(
      light: lightColor,
    );
    _saveBackgroundColorHandler(backgroundColor);
    _sendAnalyticsUseCase(
      ReaderModeBackgroundColorChanged(backgroundColor: backgroundColor),
    );
  }

  void onFontSizePressed(ReaderModeFontSize fontSize) {
    _saveFontSizeHandler(fontSize);
    _sendAnalyticsUseCase(
      ReaderModeFontSizeChanged(fontSize: fontSize),
    );
  }

  void onFontStylePressed(ReaderModeFontStyle fontStyle) {
    _saveFontStyleHandler(fontStyle);
    _sendAnalyticsUseCase(
      ReaderModeFontStyleChanged(fontStyle: fontStyle),
    );
  }

  @override
  Future<EditReaderModeSettingsState?> computeState() async => fold3(
        _saveBackgroundColorHandler,
        _saveFontSizeHandler,
        _saveFontStyleHandler,
      ).foldAll((backgroundColorHandlerOut, fontSizeHandlerOut,
          fontStyleHandlerOut, errorReport) {
        if (errorReport.isNotEmpty) {
          final report = errorReport.of(_saveBackgroundColorHandler) ??
              errorReport.of(_saveFontSizeHandler) ??
              errorReport.of(_saveFontStyleHandler);
          logger.e(report!.error);
          return state.copyWith(error: report.error);
        }

        return EditReaderModeSettingsState(
          readerModeBackgroundColor:
              backgroundColorHandlerOut ?? state.readerModeBackgroundColor,
          readerModeFontSize: fontSizeHandlerOut ?? state.readerModeFontSize,
          readerModeFontStyle: fontStyleHandlerOut ?? state.readerModeFontStyle,
        );
      });
}
