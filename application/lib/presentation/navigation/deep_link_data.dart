import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';

part 'deep_link_data.freezed.dart';

@freezed
class DeepLinkData with _$DeepLinkData {
  const factory DeepLinkData.none() = _None;

  const factory DeepLinkData.activeSearch() = _ActiveSearch;

  const factory DeepLinkData.feed({
    required UniqueId documentId,
  }) = _Feed;

  factory DeepLinkData.fromValue(DeepLinkValue value) {
    switch (value) {
      case DeepLinkValue.none:
        return const DeepLinkData.none();
      case DeepLinkValue.activeSearch:
        return const DeepLinkData.activeSearch();
    }
  }
}
