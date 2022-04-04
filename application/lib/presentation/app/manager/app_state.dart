import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';

part 'app_state.freezed.dart';

/// The state of the [AppManager].
@freezed
class AppState with _$AppState {
  const factory AppState({
    required AppTheme appTheme,
    required bool isAppPaused,
  }) = _AppState;
}
