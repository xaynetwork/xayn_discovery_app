import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';

abstract class UserInteractionsRepository {
  /// The [UserInteractions] setter method.
  void save(UserInteractions userInteractions);

  /// The [UserInteractions] getter method.
  UserInteractions get userInteractions;

  /// A stream of [RepositoryEvent]. Emits when [UserInteractions] changes.
  Stream<RepositoryEvent<UserInteractions>> watch();
}
