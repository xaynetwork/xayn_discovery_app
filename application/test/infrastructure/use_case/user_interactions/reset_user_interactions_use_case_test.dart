import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/reset_user_interactions_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockUserInteractionsRepository userInteractionsRepository;
  late ResetUserInteractionsUseCase resetUserInteractionsUseCase;

  userInteractionsRepository = MockUserInteractionsRepository();
  resetUserInteractionsUseCase =
      ResetUserInteractionsUseCase(userInteractionsRepository);

  test(
    'WHEN use case called THEN call the save method of the repository with the initial user interactions value',
    () async {
      await resetUserInteractionsUseCase.call(none);

      verify(userInteractionsRepository.save(UserInteractions.initial()));
      verifyNoMoreInteractions(userInteractionsRepository);
    },
  );
}
