import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/domain/model/entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings with _$AppSettings implements Entity {
  factory AppSettings({
    required bool isOnboardingDone,
    required AppTheme appTheme,
    required DiscoveryFeedAxis discoveryFeedAxis,
    @Default(AppSettings.globalId) UniqueId id,
  }) = _AppSettings;

  factory AppSettings.initial() => AppSettings(
        appTheme: AppTheme.system,
        isOnboardingDone: false,
        discoveryFeedAxis: DiscoveryFeedAxis.vertical,
      );

  static UniqueId globalId() => UniqueId.fromTrustedString('global');
}
