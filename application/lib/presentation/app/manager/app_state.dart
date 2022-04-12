import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';

part 'app_state.freezed.dart';

/// The state of the [AppManager].
@freezed
class AppState with _$AppState {
  const factory AppState({
    required Brightness brightness,
    required bool isAppPaused,
  }) = _AppState;
}
