import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_background_color_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_font_size_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/reader_mode_font_style_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/menu/edit_reader_mode_settings/manager/edit_reader_mode_settings_state.dart';

import '../../../bottom_sheet/move_to_collection/manager/move_to_collection_manager_test.mocks.dart';
import '../../../test_utils/utils.dart';

@GenerateMocks([SendAnalyticsUseCase])
void main() {
  late MockSaveReaderModeFontStyleUseCase saveReaderModeFontStyleUseCase;
  late MockSaveReaderModeFontSizeUseCase saveReaderModeFontSizeUseCase;
  late MockSaveReaderModeBackgroundColorUseCase
      saveReaderModeBackgroundColorUseCase;
  late MockReaderModeSettingsRepository readerModeSettingsRepository;
  late MockSendAnalyticsUseCase sendAnalyticsUseCase;

  late EditReaderModeSettingsState populatedState;

  const ReaderModeFontStyle mockFontStyle = ReaderModeFontStyle.serif;
  final ReaderModeBackgroundColor mockBackgroundColor =
      ReaderModeBackgroundColor.initial();
  const ReaderModeFontSize mockFontSize = ReaderModeFontSize.large;
  final ReaderModeSettings mockReaderModeSettings =
      ReaderModeSettings.initial();

  setUp(() {
    saveReaderModeFontStyleUseCase = MockSaveReaderModeFontStyleUseCase();
    saveReaderModeFontSizeUseCase = MockSaveReaderModeFontSizeUseCase();
    saveReaderModeBackgroundColorUseCase =
        MockSaveReaderModeBackgroundColorUseCase();
    readerModeSettingsRepository = MockReaderModeSettingsRepository();
    sendAnalyticsUseCase = MockSendAnalyticsUseCase();

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
        sendAnalyticsUseCase,
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
      setUp: () {
        when(sendAnalyticsUseCase.call(any)).thenAnswer(
          (_) async => [
            UseCaseResult.success(
              ReaderModeFontSizeChanged(fontSize: mockFontSize),
            ),
          ],
        );
      },
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
      setUp: () {
        when(sendAnalyticsUseCase.call(any)).thenAnswer(
          (_) async => [
            UseCaseResult.success(
              ReaderModeFontStyleChanged(fontStyle: mockFontStyle),
            ),
          ],
        );
      },
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
      'WHEN onLightBackgroundColorPressed is called THEN verify readerModeSettings changed',
      build: create,
      setUp: () {
        when(sendAnalyticsUseCase.call(any)).thenAnswer(
          (_) async => [
            UseCaseResult.success(
              ReaderModeBackgroundColorChanged(
                backgroundColor:
                    populatedState.readerModeBackgroundColor.copyWith(
                  light: ReaderModeBackgroundLightColor.beige,
                ),
              ),
            ),
          ],
        );
      },
      act: (manager) => manager
          .onLightBackgroundColorPressed(ReaderModeBackgroundLightColor.beige),
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
      ],
    );

    blocTest<EditReaderModeSettingsManager, EditReaderModeSettingsState>(
      'WHEN onDarkBackgroundColorPressed is called THEN verify readerModeSettings changed',
      build: create,
      setUp: () {
        when(sendAnalyticsUseCase.call(any)).thenAnswer(
          (_) async => [
            UseCaseResult.success(
              ReaderModeBackgroundColorChanged(
                backgroundColor:
                    populatedState.readerModeBackgroundColor.copyWith(
                  dark: ReaderModeBackgroundDarkColor.trueBlack,
                ),
              ),
            ),
          ],
        );
      },
      act: (manager) => manager.onDarkBackgroundColorPressed(
          ReaderModeBackgroundDarkColor.trueBlack),
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
      ],
    );
  });
}
