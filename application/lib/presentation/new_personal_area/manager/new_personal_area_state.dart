import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/manager/list_item_model.dart';

part 'new_personal_area_state.freezed.dart';

/// The state of the [NewPersonalAreaManager].
@freezed
class NewPersonalAreaState with _$NewPersonalAreaState {
  const NewPersonalAreaState._();

  const factory NewPersonalAreaState({
    /// List of collections
    required List<ListItemModel> items,

    /// Timestamp of update time (for making sure that state is emitted)
    required DateTime timestamp,

    /// Error Message
    String? errorMsg,
  }) = _NewPersonalAreaState;

  factory NewPersonalAreaState.initial() => NewPersonalAreaState(
        items: const [],
        timestamp: DateTime.now(),
      );

  factory NewPersonalAreaState.populated(
    List<ListItemModel> items,
    DateTime timestamp,
  ) =>
      NewPersonalAreaState(
        items: items,
        timestamp: timestamp,
      );
}
