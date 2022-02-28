import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode_settings/listen_reader_mode_background_color_use_case.dart';

import 'discovery_card_shadow_state.dart';

@injectable
class DiscoveryCardShadowManager extends Cubit<DiscoveryCardShadowState>
    with UseCaseBlocHelper<DiscoveryCardShadowState> {
  late final ListenReaderModeBackgroundColorUseCase
      _listenReaderModeBackgroundColorUseCase;
  late final UseCaseValueStream<ReaderModeBackgroundColor>
      _readerModeBackgroundColorSettingsHandler;

  DiscoveryCardShadowManager(
    this._listenReaderModeBackgroundColorUseCase,
    ReaderModeSettingsRepository readerModeSettingsRepository,
  ) : super(DiscoveryCardShadowState(
          readerModeBackgroundColor:
              readerModeSettingsRepository.settings.backgroundColor,
        )) {
    _initHandlers();
  }

  void _initHandlers() {
    _readerModeBackgroundColorSettingsHandler = consume(
      _listenReaderModeBackgroundColorUseCase,
      initialData: none,
    );
  }

  @override
  Future<DiscoveryCardShadowState?> computeState() async => fold(
        _readerModeBackgroundColorSettingsHandler,
      ).foldAll(
        (readerModeBackgroundColor, _) {
          if (readerModeBackgroundColor != null) {
            return state.copyWith(
              readerModeBackgroundColor: readerModeBackgroundColor,
            );
          }
        },
      );
}
