abstract class CollectionUseCaseException implements Exception {
  final String msg;

  CollectionUseCaseException(this.msg);

  @override
  String toString() => msg;
}

class CreateCollectionUseCaseException extends CollectionUseCaseException {
  CreateCollectionUseCaseException(String msg) : super(msg);
}

class CreateDefaultCollectionUseCaseException
    extends CollectionUseCaseException {
  CreateDefaultCollectionUseCaseException(String msg) : super(msg);
}

class GetCollectionCardDataUseCaseException extends CollectionUseCaseException {
  GetCollectionCardDataUseCaseException(String msg) : super(msg);
}

class RemoveCollectionUseCaseException extends CollectionUseCaseException {
  RemoveCollectionUseCaseException(String msg) : super(msg);
}

class RenameCollectionUseCaseException extends CollectionUseCaseException {
  RenameCollectionUseCaseException(String msg) : super(msg);
}

const String errorMsgRemovingExistingDefaultCollection =
    'The default collection cannot be removed';
const String errorMsgCollectionNameEmpty = 'Collection name cannot be empty';
const String errorMsgCollectionAlreadyExists = 'The collection already exists';
const String errorMsgCollectionDoesntExist = 'The collection doesn\'t exist';
