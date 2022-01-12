import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_outputs.dart';

@lazySingleton
class CollectionErrorsEnumMapper {
  String mapEnumToString(CollectionUseCaseErrorEnum errorEnum) {
    String msg;

    /// TODO replace with the POEditor string in order to have translation
    switch (errorEnum) {
      case CollectionUseCaseErrorEnum.tryingToCreateCollectionUsingExistingName:
        msg = errorMsgTryingToCreateCollectionUsingExistingName;
        break;
      case CollectionUseCaseErrorEnum.tryingToCreateAgainDefaultCollection:
        msg = errorMsgTryingToCreateAgainDefaultCollection;
        break;
      case CollectionUseCaseErrorEnum
          .tryingToGetCardDataForNotExistingCollection:
        msg = errorMsgTryingToGetCardDataForNotExistingCollection;
        break;
      case CollectionUseCaseErrorEnum.tryingToRemoveDefaultCollection:
        msg = errorMsgTryingToRemoveDefaultCollection;
        break;
      case CollectionUseCaseErrorEnum.tryingToRemoveNotExistingCollection:
        msg = errorMsgTryingToRemoveNotExistingCollection;
        break;
      case CollectionUseCaseErrorEnum.tryingToRenameCollectionUsingExistingName:
        msg = errorMsgTryingToRenameCollectionUsingExistingName;
        break;
      case CollectionUseCaseErrorEnum.tryingToRenameNotExistingCollection:
        msg = errorMsgTryingToRenameNotExistingCollection;
        break;
    }
    return msg;
  }
}

const String errorMsgTryingToCreateCollectionUsingExistingName =
    'Trying to create a collection using an existing name';
const String errorMsgTryingToCreateAgainDefaultCollection =
    'Trying to create again the default collection';
const String errorMsgTryingToGetCardDataForNotExistingCollection =
    'Trying to get card data for a collection that doesn\'t exist';
const String errorMsgTryingToRemoveDefaultCollection =
    'Trying to remove the default collection';
const String errorMsgTryingToRemoveNotExistingCollection =
    'Trying to remove a collection that doesn\t exist';
const String errorMsgTryingToRenameCollectionUsingExistingName =
    'Trying to rename a collection using an existing name';
const String errorMsgTryingToRenameNotExistingCollection =
    'Trying to rename a collection that doesn\t exist';
