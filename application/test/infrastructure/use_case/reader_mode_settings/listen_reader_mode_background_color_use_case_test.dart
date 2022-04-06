import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_background_color_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockReaderModeSettingsRepository repository;
  late ListenReaderModeBackgroundColorUseCase useCase;

  final mockBackgroundColor = ReaderModeBackgroundColor.initial().copyWith(
    dark: ReaderModeBackgroundDarkColor.trueBlack,
  );

  final settingsWithBlackBackgroundColor =
      ReaderModeSettings.initial().copyWith(
    backgroundColor: mockBackgroundColor,
  );
  final settingsWithSerifFontStyle = settingsWithBlackBackgroundColor.copyWith(
    fontStyle: ReaderModeFontStyle.serif,
  );

  setUp(() {
    repository = MockReaderModeSettingsRepository();
    useCase = ListenReaderModeBackgroundColorUseCase(repository);

    when(repository.settings)
        .thenAnswer((_) => settingsWithBlackBackgroundColor);
  });

  group('Listen Reader Mode Background Color Use Case', () {
    useCaseTest<ListenReaderModeBackgroundColorUseCase, None,
        ReaderModeBackgroundColor>(
      'WHEN ReaderModeSettingsRepository emit single value THEN usecase emit it as well',
      setUp: () {
        when(repository.watch()).thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              newObject: settingsWithBlackBackgroundColor,
              id: settingsWithBlackBackgroundColor.id,
            ),
          ),
        );
      },
      build: () => useCase,
      input: [none],
      expect: [useCaseSuccess(mockBackgroundColor)],
    );

    useCaseTest<ListenReaderModeBackgroundColorUseCase, None,
        ReaderModeBackgroundColor>(
      'WHEN ReaderModeSettingsRepository emit multiple values one of which is background color THEN usecase emits only one',
      setUp: () {
        when(repository.watch()).thenAnswer(
          (_) => Stream.fromIterable([
            ChangedEvent(
              newObject: settingsWithBlackBackgroundColor,
              id: settingsWithBlackBackgroundColor.id,
            ),
            ChangedEvent(
              newObject: settingsWithSerifFontStyle,
              id: settingsWithSerifFontStyle.id,
            ),
          ]),
        );
      },
      build: () => useCase,
      input: [none],
      expect: [
        useCaseSuccess(mockBackgroundColor),
      ],
    );

    useCaseTest<ListenReaderModeBackgroundColorUseCase, None,
        ReaderModeBackgroundColor>(
      'WHEN ReaderModeSettingsRepository emit multiple identical events of background color changes THEN usecase emits only one',
      setUp: () {
        when(repository.watch()).thenAnswer(
          (_) => Stream.fromIterable([
            ChangedEvent(
              newObject: settingsWithBlackBackgroundColor,
              id: settingsWithBlackBackgroundColor.id,
            ),
            ChangedEvent(
              newObject: settingsWithBlackBackgroundColor,
              id: settingsWithSerifFontStyle.id,
            ),
          ]),
        );
      },
      build: () => useCase,
      input: [none],
      expect: [
        useCaseSuccess(mockBackgroundColor),
      ],
    );

    useCaseTest<ListenReaderModeBackgroundColorUseCase, None,
        ReaderModeBackgroundColor>(
      'WHEN ReaderModeSettingsRepository emit multiple different events of background color changes THEN usecase emits all of them',
      setUp: () {
        when(repository.watch()).thenAnswer(
          (_) => Stream.fromIterable([
            ChangedEvent(
              newObject: settingsWithBlackBackgroundColor,
              id: settingsWithBlackBackgroundColor.id,
            ),
            ChangedEvent(
              newObject: settingsWithBlackBackgroundColor.copyWith(
                backgroundColor: mockBackgroundColor.copyWith(
                  dark: ReaderModeBackgroundDarkColor.dark,
                ),
              ),
              id: settingsWithSerifFontStyle.id,
            ),
          ]),
        );
      },
      build: () => useCase,
      input: [none],
      expect: [
        useCaseSuccess(mockBackgroundColor),
        useCaseSuccess(
          mockBackgroundColor.copyWith(
            dark: ReaderModeBackgroundDarkColor.dark,
          ),
        ),
      ],
    );
  });
}
