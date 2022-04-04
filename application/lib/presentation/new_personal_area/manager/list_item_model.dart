import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'list_item_model.freezed.dart';

/// Data model used for the list of item in the [NewPersonalAreaState]
@freezed
class ListItemModel with _$ListItemModel {
  const factory ListItemModel.collection({
    required UniqueId id,
    required Collection collection,
  }) = _ListItemModelCollection;

  const factory ListItemModel.payment({
    required UniqueId id,
    required DateTime trialEndDate,
  }) = _ListItemModelPayment;
}
