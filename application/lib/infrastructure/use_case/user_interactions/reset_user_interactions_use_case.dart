import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';

class ResetUserInteractionsUseCase extends UseCase<None, None> {
  final UserInteractionsRepository _userInteractionsRepository;

  ResetUserInteractionsUseCase(this._userInteractionsRepository);

  @override
  Stream<None> transaction(None param) async* {
    _userInteractionsRepository.save(UserInteractions.initial());

    yield none;
  }
}
