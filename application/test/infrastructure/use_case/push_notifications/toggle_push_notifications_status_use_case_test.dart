import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/toggle_push_notifications_state_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockLocalNotificationsService localNotificationsService;
  late MockRemoteNotificationsService remoteNotificationsService;
  late MockGetPushNotificationsStatusUseCase getPushNotificationsStatusUseCase;
  late MockSavePushNotificationsStatusUseCase
      savePushNotificationsStatusUseCase;
  late MockAreLocalNotificationsAllowedUseCase
      areLocalNotificationsAllowedUseCase;
  late TogglePushNotificationsStatusUseCase
      togglePushNotificationsStatusUseCase;

  localNotificationsService = MockLocalNotificationsService();
  remoteNotificationsService = MockRemoteNotificationsService();
  getPushNotificationsStatusUseCase = MockGetPushNotificationsStatusUseCase();
  savePushNotificationsStatusUseCase = MockSavePushNotificationsStatusUseCase();
  areLocalNotificationsAllowedUseCase =
      MockAreLocalNotificationsAllowedUseCase();
  togglePushNotificationsStatusUseCase = TogglePushNotificationsStatusUseCase(
    localNotificationsService,
    remoteNotificationsService,
    getPushNotificationsStatusUseCase,
    savePushNotificationsStatusUseCase,
    areLocalNotificationsAllowedUseCase,
  );

  group(
    'WHEN user did not interact with push notifications settings',
    () {
      useCaseTest(
        'WHEN user toggles the notification switch AND notifications are allowed THEN nothing happens',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => false);
          when(savePushNotificationsStatusUseCase(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => true);
          when(remoteNotificationsService.userNotificationsEnabled)
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => togglePushNotificationsStatusUseCase,
        input: [none],
        verify: (_) {
          verify(savePushNotificationsStatusUseCase(none)).called(1);
          verify(remoteNotificationsService.userNotificationsEnabled).called(1);
          verify(remoteNotificationsService.enableNotifications()).called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN user toggles the notification switch AND notifications are not allowed THEN a native dialog to enable notifications is shown',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => false);
          when(savePushNotificationsStatusUseCase(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.userNotificationsEnabled)
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => togglePushNotificationsStatusUseCase,
        input: [none],
        verify: (_) {
          verify(remoteNotificationsService.enableNotifications()).called(1);
          verify(savePushNotificationsStatusUseCase(none)).called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );

  group(
    'WHEN user interacted with push notifications settings',
    () {
      useCaseTest(
        'WHEN user toggles the notification switch AND notifications are allowed THEN nothing happens',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          when(savePushNotificationsStatusUseCase(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => true);
          when(remoteNotificationsService.userNotificationsEnabled)
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => togglePushNotificationsStatusUseCase,
        input: [none],
        verify: (_) {
          verify(remoteNotificationsService.enableNotifications()).called(1);
          verifyNever(savePushNotificationsStatusUseCase(none));
        },
        expect: [
          useCaseSuccess(none),
        ],
      );

      useCaseTest(
        'WHEN user toggles the notification switch AND notifications are not allowed THEN redirect the user to settings with notifications page opened',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          when(savePushNotificationsStatusUseCase(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => togglePushNotificationsStatusUseCase,
        input: [none],
        verify: (_) {
          verify(localNotificationsService.openNotificationsPage()).called(1);
          verifyNever(remoteNotificationsService.enableNotifications());
          verifyNever(savePushNotificationsStatusUseCase(none));
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );
}
