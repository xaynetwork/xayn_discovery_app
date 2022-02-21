import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_settings_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockReaderModeSettingsRepository repository;
  late ListenReaderModeSettingsUseCase useCase;

  final settingsWithBlackBackgroundColor =
      ReaderModeSettings.initial().copyWith(
    backgroundColor: ReaderModeBackgroundColor.black,
  );
  final settingsWithSerifFontStyle = settingsWithBlackBackgroundColor.copyWith(
    fontStyle: ReaderModeFontStyle.serif,
  );

  setUp(() {
    repository = MockReaderModeSettingsRepository();
    useCase = ListenReaderModeSettingsUseCase(repository);

    when(repository.settings)
        .thenAnswer((_) => settingsWithBlackBackgroundColor);
  });

  useCaseTest<ListenReaderModeSettingsUseCase, None, ReaderModeSettings>(
    'WHEN ReaderModeSettingsRepository emit single value THEN useCase emit it as well',
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
    expect: [useCaseSuccess(settingsWithBlackBackgroundColor)],
  );

  useCaseTest<ListenReaderModeSettingsUseCase, None, ReaderModeSettings>(
    'WHEN ReaderModeSettingsRepository emit multiple values THEN useCase emit them as well',
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
      useCaseSuccess(settingsWithBlackBackgroundColor),
      useCaseSuccess(settingsWithSerifFontStyle),
    ],
  );
}
