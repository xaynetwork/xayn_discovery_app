import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';

@injectable
class ResetNumberOfScrollsPerSessionUseCase extends UseCase<None, None> {
  final UserInteractionsRepository _userInteractionsRepository;

  ResetNumberOfScrollsPerSessionUseCase(this._userInteractionsRepository);

  @override
  Stream<None> transaction(None param) async* {
    final userInteractions = _userInteractionsRepository.userInteractions;
    final updatedUserInteractions = userInteractions.copyWith(
      numberOfScrollsPerSession: 0,
    );
    _userInteractionsRepository.save(updatedUserInteractions);
    yield none;
  }
}
