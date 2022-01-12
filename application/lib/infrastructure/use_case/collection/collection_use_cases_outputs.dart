import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';

part 'collection_use_cases_outputs.freezed.dart';

enum CollectionUseCaseErrorEnum {
  tryingToCreateCollectionUsingExistingName,
  tryingToCreateAgainDefaultCollection,
  tryingToGetCardDataForNotExistingCollection,
  tryingToRemoveDefaultCollection,
  tryingToRemoveNotExistingCollection,
  tryingToRenameCollectionUsingExistingName,
  tryingToRenameNotExistingCollection,
}

@freezed
class CollectionUseCaseGenericOut with _$CollectionUseCaseGenericOut {
  const factory CollectionUseCaseGenericOut.success(Collection collection) =
      _CollectionUseCaseGenericOutSuccess;
  const factory CollectionUseCaseGenericOut.failure(
    CollectionUseCaseErrorEnum error,
  ) = _CollectionUseCaseGenericOutFailure;
}

@freezed
class GetCollectionCardDataUseCaseOut with _$GetCollectionCardDataUseCaseOut {
  const factory GetCollectionCardDataUseCaseOut.success({
    required int numOfItems,
    Uint8List? image,
  }) = _GetCollectionCardDataUseCaseOutSuccess;
  const factory GetCollectionCardDataUseCaseOut.failure(
    CollectionUseCaseErrorEnum error,
  ) = _GetCollectionCardDataUseCaseOutFailure;
}
