import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/presentation/navigation/deep_link_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'deep_link_data.freezed.dart';

@freezed
class DeepLinkData with _$DeepLinkData {
  const factory DeepLinkData.none() = _None;

  const factory DeepLinkData.activeSearch() = _ActiveSearch;

  const factory DeepLinkData.feed({
    required UniqueId documentId,
  }) = _Feed;

  const factory DeepLinkData.cardDetails({
    required Document document,
  }) = _CardDetails;

  factory DeepLinkData.fromValue(DeepLinkValue value, [Document? document]) {
    switch (value) {
      case DeepLinkValue.none:
        return const DeepLinkData.none();
      case DeepLinkValue.activeSearch:
        return const DeepLinkData.activeSearch();
      case DeepLinkValue.cardDetailsFromDocument:
        if (document != null) {
          return DeepLinkData.cardDetails(document: document);
        } else {
          return const DeepLinkData.none();
        }
    }
  }
}
