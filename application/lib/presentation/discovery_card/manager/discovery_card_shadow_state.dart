import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';

part 'discovery_card_shadow_state.freezed.dart';

/// The state of the [DiscoveryCardShadowManager].
/// It is used to configure shadow of Discovery Card's headline image in reader mode
@freezed
class DiscoveryCardShadowState with _$DiscoveryCardShadowState {
  const DiscoveryCardShadowState._();

  const factory DiscoveryCardShadowState({
    required ReaderModeBackgroundColor readerModeBackgroundColor,
  }) = _DiscoveryCardShadowState;
}
