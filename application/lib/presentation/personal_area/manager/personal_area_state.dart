import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';

part 'personal_area_state.freezed.dart';

/// The state of the [PersonalAreaManager].
@freezed
class PersonalAreaState with _$PersonalAreaState {
  const PersonalAreaState._();

  const factory PersonalAreaState({
    DateTime? trialEndDate,
  }) = _PersonalAreaState;

  factory PersonalAreaState.initial() => const PersonalAreaState(
        trialEndDate: null,
      );
}
