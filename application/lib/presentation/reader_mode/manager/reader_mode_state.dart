import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';

part 'reader_mode_state.freezed.dart';

/// The state of the [DiscoveryFeedManager].
@freezed
class ReaderModeState with _$ReaderModeState {
  const ReaderModeState._();

  const factory ReaderModeState({
    Uri? uri,
    required ReaderModeSettings readerModeSettings,
  }) = _ReaderModeState;

  factory ReaderModeState.empty({
    required ReaderModeSettings readerModeSettings,
  }) =>
      ReaderModeState(
        uri: null,
        readerModeSettings: readerModeSettings,
      );
}
