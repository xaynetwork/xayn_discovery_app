import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_state.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockSaveReaderModeFontStyleUseCase saveReaderModeFontStyleUseCase;
  late MockSaveReaderModeFontSizeUseCase saveReaderModeFontSizeUseCase;
  late MockSaveReaderModeBackgroundColorUseCase
      saveReaderModeBackgroundColorUseCase;
  late MockReaderModeSettingsRepository readerModeSettingsRepository;
  late EditReaderModeSettingsState populatedState;

  const ReaderModeFontStyle mockFontStyle = ReaderModeFontStyle.serif;
  const ReaderModeBackgroundColor mockBackgroundColor =
      ReaderModeBackgroundColor.beige;
  const ReaderModeFontSize mockFontSize = ReaderModeFontSize.large;
  final ReaderModeSettings mockReaderModeSettings =
      ReaderModeSettings.initial();

  setUp(() {
    saveReaderModeFontStyleUseCase = MockSaveReaderModeFontStyleUseCase();
    saveReaderModeFontSizeUseCase = MockSaveReaderModeFontSizeUseCase();
    saveReaderModeBackgroundColorUseCase =
        MockSaveReaderModeBackgroundColorUseCase();
    readerModeSettingsRepository = MockReaderModeSettingsRepository();

    populatedState = EditReaderModeSettingsState(
      readerModeBackgroundColor: mockReaderModeSettings.backgroundColor,
      readerModeFontStyle: mockReaderModeSettings.fontStyle,
      readerModeFontSize: mockReaderModeSettings.fontSize,
    );

    when(readerModeSettingsRepository.settings)
        .thenReturn(mockReaderModeSettings);

    when(saveReaderModeFontStyleUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(saveReaderModeFontSizeUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(saveReaderModeBackgroundColorUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(saveReaderModeFontStyleUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(mockFontStyle));
    when(saveReaderModeFontSizeUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(mockFontSize));
    when(saveReaderModeBackgroundColorUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(mockBackgroundColor));
  });

  EditReaderModeSettingsManager create() => EditReaderModeSettingsManager(
        saveReaderModeFontSizeUseCase,
        saveReaderModeBackgroundColorUseCase,
        saveReaderModeFontStyleUseCase,
        readerModeSettingsRepository,
      );

  group('Edit Reader Mode Settings Manager ', () {
    blocTest<EditReaderModeSettingsManager, EditReaderModeSettingsState>(
      'GIVEN manager WHEN it is created THEN verify readerModeSettings received',
      build: create,
      verify: (manager) {
        verify(readerModeSettingsRepository.settings).called(3);
        verifyNoMoreInteractions(readerModeSettingsRepository);
      },
      expect: () => [populatedState],
    );

    blocTest<EditReaderModeSettingsManager, EditReaderModeSettingsState>(
      'WHEN onFontSizePressed is called THEN verify readerModeSettings changed',
      build: create,
      act: (manager) => manager.onFontSizePressed(mockFontSize),
      verify: (manager) {
        verifyInOrder([
          saveReaderModeBackgroundColorUseCase.transform(any),
          saveReaderModeFontSizeUseCase.transform(any),
          saveReaderModeFontStyleUseCase.transform(any),
          saveReaderModeFontSizeUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(saveReaderModeFontStyleUseCase);
        verifyNoMoreInteractions(saveReaderModeFontSizeUseCase);
        verifyNoMoreInteractions(saveReaderModeBackgroundColorUseCase);
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(readerModeFontSize: mockFontSize)
      ],
    );

    blocTest<EditReaderModeSettingsManager, EditReaderModeSettingsState>(
      'WHEN onFontStylePressed is called THEN verify readerModeSettings changed',
      build: create,
      act: (manager) => manager.onFontStylePressed(mockFontStyle),
      verify: (manager) {
        verifyInOrder([
          saveReaderModeBackgroundColorUseCase.transform(any),
          saveReaderModeFontSizeUseCase.transform(any),
          saveReaderModeFontStyleUseCase.transform(any),
          saveReaderModeFontStyleUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(saveReaderModeFontStyleUseCase);
        verifyNoMoreInteractions(saveReaderModeFontSizeUseCase);
        verifyNoMoreInteractions(saveReaderModeBackgroundColorUseCase);
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(readerModeFontStyle: mockFontStyle)
      ],
    );

    blocTest<EditReaderModeSettingsManager, EditReaderModeSettingsState>(
      'WHEN onBackgroundColorPressed is called THEN verify readerModeSettings changed',
      build: create,
      act: (manager) => manager.onBackgroundColorPressed(mockBackgroundColor),
      verify: (manager) {
        verifyInOrder([
          saveReaderModeBackgroundColorUseCase.transform(any),
          saveReaderModeFontSizeUseCase.transform(any),
          saveReaderModeFontStyleUseCase.transform(any),
          saveReaderModeBackgroundColorUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(saveReaderModeFontStyleUseCase);
        verifyNoMoreInteractions(saveReaderModeFontSizeUseCase);
        verifyNoMoreInteractions(saveReaderModeBackgroundColorUseCase);
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(readerModeBackgroundColor: mockBackgroundColor)
      ],
    );
  });
}
