import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/model/entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings with _$AppSettings implements DbEntity {
  factory AppSettings({
    required bool isOnboardingDone,
    required AppTheme appTheme,
    required DiscoveryFeedAxis discoveryFeedAxis,
    required UniqueId id,
  }) = _AppSettings;

  factory AppSettings.global({
    required bool isOnboardingDone,
    required AppTheme appTheme,
    required DiscoveryFeedAxis discoveryFeedAxis,
  }) =>
      AppSettings(
        isOnboardingDone: isOnboardingDone,
        appTheme: appTheme,
        discoveryFeedAxis: discoveryFeedAxis,
        id: AppSettings.globalId(),
      );

  factory AppSettings.initial() => AppSettings.global(
        isOnboardingDone: false,
        appTheme: AppTheme.system,
        discoveryFeedAxis: DiscoveryFeedAxis.vertical,
      );

  static UniqueId globalId() => UniqueId.fromTrustedString('global');
}
