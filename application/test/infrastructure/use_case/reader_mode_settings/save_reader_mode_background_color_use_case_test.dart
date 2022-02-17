import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/save_reader_mode_background_color_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockReaderModeSettingsRepository repository;
  late SaveReaderModeBackgroundColorUseCase useCase;

  const backgroundColor = ReaderModeBackgroundColor.beige;

  setUp(() {
    repository = MockReaderModeSettingsRepository();
    useCase = SaveReaderModeBackgroundColorUseCase(repository);
    when(repository.settings).thenAnswer((_) => ReaderModeSettings.initial());
  });

  test(
    'GIVEN backgroundColor to store in ReaderModeSettings WHEN call useCase as Future THEN update value in repository',
    () async {
      await useCase.call(backgroundColor);

      verifyInOrder([
        repository.settings,
        repository.save(
          ReaderModeSettings.initial()
              .copyWith(backgroundColor: backgroundColor),
        ),
      ]);
      verifyNoMoreInteractions(repository);
    },
  );
}
