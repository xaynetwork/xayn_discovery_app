import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';

part 'settings_state.freezed.dart';

@freezed
class SettingsScreenState with _$SettingsScreenState {
  const factory SettingsScreenState.initial() = _Initial;

  const factory SettingsScreenState.ready({
    required AppTheme theme,
    required AppVersion appVersion,
    required bool isPaymentEnabled,
    required bool arePushNotificationsActive,
    required bool areLocalNotificationsEnabled,
    required bool areRemoteNotificationsEnabled,
    required SubscriptionStatus subscriptionStatus,
  }) = SettingsScreenStateReady;
}
