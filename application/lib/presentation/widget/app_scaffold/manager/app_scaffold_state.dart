import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_scaffold_state.freezed.dart';

@freezed
class AppScaffoldState with _$AppScaffoldState {
  const factory AppScaffoldState({
    required ConnectivityResult connectivityResult,
  }) = _AppScaffoldState;

  factory AppScaffoldState.initial() => const AppScaffoldState(
        connectivityResult: ConnectivityResult.mobile,
      );
}
