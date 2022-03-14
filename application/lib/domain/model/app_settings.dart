import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'app_settings.freezed.dart';

@freezed
class AppSettings extends DbEntity with _$AppSettings {
  factory AppSettings._({
    required bool isOnboardingDone,
    required bool autoPlayTextToSpeech,
    required AppTheme appTheme,
    required UniqueId id,
  }) = _AppSettings;

  factory AppSettings.global({
    required bool isOnboardingDone,
    required bool autoPlayTextToSpeech,
    required AppTheme appTheme,
  }) =>
      AppSettings._(
        isOnboardingDone: isOnboardingDone,
        autoPlayTextToSpeech: autoPlayTextToSpeech,
        appTheme: appTheme,
        id: AppSettings.globalId,
      );

  factory AppSettings.initial() => AppSettings.global(
        isOnboardingDone: false,
        autoPlayTextToSpeech: true,
        appTheme: AppTheme.system,
      );

  static UniqueId globalId =
      const UniqueId.fromTrustedString('app_settings_id');
}
