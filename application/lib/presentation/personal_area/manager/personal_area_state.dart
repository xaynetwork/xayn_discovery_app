import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/list_item_model.dart';

part 'personal_area_state.freezed.dart';

/// The state of the [PersonalAreaManager].
@freezed
class PersonalAreaState with _$PersonalAreaState {
  const PersonalAreaState._();

  const factory PersonalAreaState({
    /// List of collections
    required List<ListItemModel> items,

    /// Error Message
    String? errorMsg,
  }) = _PersonalAreaState;

  factory PersonalAreaState.initial({DateTime? timestamp}) =>
      const PersonalAreaState(
        items: [],
      );

  factory PersonalAreaState.populated(
    List<ListItemModel> items,
  ) =>
      PersonalAreaState(
        items: items,
      );
}
