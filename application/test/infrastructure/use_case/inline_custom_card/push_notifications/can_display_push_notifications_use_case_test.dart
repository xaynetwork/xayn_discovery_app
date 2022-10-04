import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/can_display_push_notifications_card_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockGetPushNotificationsStatusUseCase getPushNotificationsStatus;
  late MockAppStatusRepository appStatusRepository;
  late MockFeatureManager featureManager;
  late CanDisplayPushNotificationsCardUseCase
      canDisplayPushNotificationsCardUseCase;

  featureManager = MockFeatureManager();
  appStatusRepository = MockAppStatusRepository();
  getPushNotificationsStatus = MockGetPushNotificationsStatusUseCase();
  canDisplayPushNotificationsCardUseCase =
      CanDisplayPushNotificationsCardUseCase(
    getPushNotificationsStatus,
    appStatusRepository,
    featureManager,
  );

  final initialAppStatus = AppStatus.initial();

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'CanDisplayPushNotificationsCardUseCase',
    () {
      group(
        'Feature flag ENABLED',
        () {
          useCaseTest(
            'WHEN userDidChangePushNotifications is true THEN return false',
            setUp: () {
              when(featureManager.areRemoteNotificationsEnabled)
                  .thenReturn(true);
              when(getPushNotificationsStatus.singleOutput(none))
                  .thenAnswer((_) async => true);
            },
            build: () => canDisplayPushNotificationsCardUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );

          useCaseTest(
            'WHEN userDidChangePushNotifications is false THEN return true',
            setUp: () {
              when(featureManager.areRemoteNotificationsEnabled)
                  .thenReturn(true);
              when(getPushNotificationsStatus.singleOutput(none))
                  .thenAnswer((_) async => false);
            },
            build: () => canDisplayPushNotificationsCardUseCase,
            input: [none],
            expect: [
              useCaseSuccess(true),
            ],
          );
        },
      );
      group(
        'Feature flag DISABLED',
        () {
          useCaseTest(
            'WHEN calling the use case with flag disabled THEN return false',
            setUp: () {
              when(featureManager.areRemoteNotificationsEnabled)
                  .thenReturn(false);
            },
            build: () => canDisplayPushNotificationsCardUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );
        },
      );
    },
  );
}
