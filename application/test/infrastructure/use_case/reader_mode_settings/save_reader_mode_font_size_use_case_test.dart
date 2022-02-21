import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_font_size_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockReaderModeSettingsRepository repository;
  late SaveReaderModeFontSizeUseCase useCase;

  const fontSize = ReaderModeFontSize.medium;

  setUp(() {
    repository = MockReaderModeSettingsRepository();
    useCase = SaveReaderModeFontSizeUseCase(repository);
    when(repository.settings).thenAnswer((_) => ReaderModeSettings.initial());
  });

  test(
    'GIVEN fontSize to store in ReaderModeSettings WHEN call useCase as Future THEN update value in repository',
    () async {
      await useCase.call(fontSize);

      verifyInOrder([
        repository.settings,
        repository.save(
          ReaderModeSettings.initial().copyWith(fontSize: fontSize),
        ),
      ]);
      verifyNoMoreInteractions(repository);
    },
  );
}
