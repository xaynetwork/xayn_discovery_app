import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'list_item_model.freezed.dart';

/// Data model used for the list of item in the [NewPersonalAreaState]
@freezed
class ListItemModel with _$ListItemModel {
  @Assert('collection != null || trialEndDate != null',
      'one between collection or trialEndDate must be not null')
  factory ListItemModel({
    required UniqueId id,
    Collection? collection,
    DateTime? trialEndDate,
  }) = _ListItemModel;
}

extension ListItemModelExtension on ListItemModel {
  bool get isCollection => collection != null;
  bool get isTrialBanner => !isCollection;
}
