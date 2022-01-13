import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

@lazySingleton
class CollectionErrorsEnumMapper {
  String mapEnumToString(CollectionUseCaseError errorEnum) {
    String msg;

    /// TODO replace with the POEditor string in order to have translation
    switch (errorEnum) {
      case CollectionUseCaseError.tryingToCreateCollectionUsingExistingName:
        msg = Strings.errorMsgTryingToCreateCollectionUsingExistingName;
        break;
      case CollectionUseCaseError.tryingToCreateAgainDefaultCollection:
        msg = Strings.errorMsgTryingToCreateAgainDefaultCollection;
        break;
      case CollectionUseCaseError.tryingToGetCardDataForNotExistingCollection:
        msg = Strings.errorMsgTryingToGetCardDataForNotExistingCollection;
        break;
      case CollectionUseCaseError.tryingToRemoveDefaultCollection:
        msg = Strings.errorMsgTryingToRemoveDefaultCollection;
        break;
      case CollectionUseCaseError.tryingToRemoveNotExistingCollection:
        msg = Strings.errorMsgTryingToRemoveNotExistingCollection;
        break;
      case CollectionUseCaseError.tryingToRenameCollectionUsingExistingName:
        msg = Strings.errorMsgTryingToRenameCollectionUsingExistingName;
        break;
      case CollectionUseCaseError.tryingToRenameNotExistingCollection:
        msg = Strings.errorMsgTryingToRenameNotExistingCollection;
        break;
    }
    return msg;
  }
}
