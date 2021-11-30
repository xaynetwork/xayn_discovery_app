import 'package:xayn_discovery_app/domain/model/app_theme.dart';

abstract class AppSettings {
  bool get isOnboardingDone;
  AppTheme get appTheme;
}
