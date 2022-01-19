import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings extends DbEntity with _$AppSettings {
  /// using a late final here for convenience,
  /// this way, if
  /// - a = AppSettings.initial();
  /// - b = AppSettings.initial();
  /// then a == b // is true
  /// ...both constructors will 'create' an installation ID, but they then
  /// reuse the late final version always.
  static late final nextInstallationId = UniqueId();

  factory AppSettings._({
    required bool isOnboardingDone,
    required AppTheme appTheme,
    required UniqueId id,
    // A generated key, which is unique for every app installation.
    required UniqueId installationId,
  }) = _AppSettings;

  factory AppSettings.global({
    required bool isOnboardingDone,
    required AppTheme appTheme,
    UniqueId? installationId,
  }) =>
      AppSettings._(
        isOnboardingDone: isOnboardingDone,
        appTheme: appTheme,
        id: AppSettings.globalId,
        installationId: installationId ?? nextInstallationId,
      );

  factory AppSettings.initial() => AppSettings.global(
        isOnboardingDone: false,
        appTheme: AppTheme.system,
      );

  static UniqueId globalId =
      const UniqueId.fromTrustedString('app_settings_id');
}
