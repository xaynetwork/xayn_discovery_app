import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_style_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockReaderModeSettingsRepository repository;
  late SaveReaderModeFontStyleUseCase useCase;

  const fontStyle = ReaderModeFontStyle.serif;

  setUp(() {
    repository = MockReaderModeSettingsRepository();
    useCase = SaveReaderModeFontStyleUseCase(repository);
    when(repository.settings).thenAnswer((_) => ReaderModeSettings.initial());
  });

  test(
    'GIVEN fontStyle to store in ReaderModeSettings WHEN call useCase as Future THEN update value in repository',
    () async {
      await useCase.call(fontStyle);

      verifyInOrder([
        repository.settings,
        repository.save(
          ReaderModeSettings.initial().copyWith(fontStyle: fontStyle),
        ),
      ]);
      verifyNoMoreInteractions(repository);
    },
  );
}
