const String errorMessageCreatingExistingDefaultCollection =
    'Trying to create again the default collection';
const String errorMessageRemovingExistingDefaultCollection =
    'Trying to remove the default collection';
const String errorMessageRenamingDefaultCollection =
    'Trying to rename the default collection';
const String errorMessageRenamingNotExistingCollection =
    'Trying to rename a collection that doesn\'t exist';
const String errorMessageRemovingNotExistingCollection =
    'Trying to remove a collection that doesn\'t exist';
const String errorMessageCollectionNameEmpty =
    'The name of the default collection cannot be empty';

class CollectionUseCaseException implements Exception {
  final String msg;

  CollectionUseCaseException(this.msg);

  @override
  String toString() => msg;
}
