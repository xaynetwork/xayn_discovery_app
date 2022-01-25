import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

@lazySingleton
class CollectionErrorsEnumMapper {
  String mapEnumToString(CollectionUseCaseError errorEnum) {
    String msg;

    switch (errorEnum) {
      case CollectionUseCaseError.tryingToCreateCollectionUsingExistingName:
        msg = R.strings.errorMsgCollectionNameAlreadyUsed;
        break;
      case CollectionUseCaseError.tryingToCreateAgainDefaultCollection:
        msg = R.strings.errorMsgTryingToCreateAgainDefaultCollection;
        break;
      case CollectionUseCaseError.tryingToGetCardDataForNotExistingCollection:
        msg = R.strings.errorMsgCollectionDoesntExist;
        break;
      case CollectionUseCaseError.tryingToRemoveDefaultCollection:
        msg = R.strings.errorMsgTryingToRemoveDefaultCollection;
        break;
      case CollectionUseCaseError.tryingToRemoveNotExistingCollection:
        msg = R.strings.errorMsgCollectionDoesntExist;
        break;
      case CollectionUseCaseError.tryingToRenameCollectionUsingExistingName:
        msg = R.strings.errorMsgCollectionNameAlreadyUsed;
        break;
      case CollectionUseCaseError.tryingToRenameNotExistingCollection:
        msg = R.strings.errorMsgCollectionDoesntExist;
        break;
    }
    return msg;
  }
}
