import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';

part 'contact_state.freezed.dart';

@freezed
class ContactScreenState with _$ContactScreenState {
  const factory ContactScreenState.initial() = _Initial;

  const factory ContactScreenState.ready({
    required AppTheme theme,
    required AppVersion appVersion,
    required bool isPaymentEnabled,
  }) = ContactScreenStateReady;
}
