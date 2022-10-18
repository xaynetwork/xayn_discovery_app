import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/handle_push_notifications_card_clicked_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockLocalNotificationsService localNotificationsService;
  late MockRemoteNotificationsService remoteNotificationsService;
  late MockGetPushNotificationsStatusUseCase getPushNotificationsStatusUseCase;
  late MockSavePushNotificationsStatusUseCase
      savePushNotificationsStatusUseCase;
  late MockAreLocalNotificationsAllowedUseCase
      areLocalNotificationsAllowedUseCase;
  late HandlePushNotificationsCardClickedUseCase
      handlePushNotificationsCardClickedUseCase;

  localNotificationsService = MockLocalNotificationsService();
  remoteNotificationsService = MockRemoteNotificationsService();
  getPushNotificationsStatusUseCase = MockGetPushNotificationsStatusUseCase();
  savePushNotificationsStatusUseCase = MockSavePushNotificationsStatusUseCase();
  areLocalNotificationsAllowedUseCase =
      MockAreLocalNotificationsAllowedUseCase();
  handlePushNotificationsCardClickedUseCase =
      HandlePushNotificationsCardClickedUseCase(
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
        'WHEN use case is called AND notifications are allowed THEN do nothing',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => false);
          when(savePushNotificationsStatusUseCase.call(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => true);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => handlePushNotificationsCardClickedUseCase,
        input: [none],
        verify: (_) {
          verifyNever(remoteNotificationsService.enableNotifications());
          verifyNever(savePushNotificationsStatusUseCase.call(none));
        },
        expect: [
          useCaseSuccess(true),
        ],
      );

      useCaseTest(
        'WHEN use case is called AND notifications are not allowed THEN a native dialog to enable notifications is shown',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => false);
          when(savePushNotificationsStatusUseCase.call(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => handlePushNotificationsCardClickedUseCase,
        input: [none],
        verify: (_) {
          verify(remoteNotificationsService.enableNotifications()).called(1);
          verify(savePushNotificationsStatusUseCase.call(none)).called(1);
        },
        expect: [
          useCaseSuccess(false),
        ],
      );
    },
  );

  group(
    'WHEN user interacted with push notifications settings',
    () {
      useCaseTest(
        'WHEN use case is called AND notifications are allowed THEN do nothing',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          when(savePushNotificationsStatusUseCase.call(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => true);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => handlePushNotificationsCardClickedUseCase,
        input: [none],
        verify: (_) {
          verifyNever(remoteNotificationsService.enableNotifications());
          verifyNever(savePushNotificationsStatusUseCase.call(none));
        },
        expect: [
          useCaseSuccess(true),
        ],
      );

      useCaseTest(
        'WHEN use case is called AND notifications are not allowed THEN redirect the user to settings with notifications page opened',
        setUp: () {
          when(getPushNotificationsStatusUseCase.singleOutput(none))
              .thenAnswer((_) async => true);
          when(savePushNotificationsStatusUseCase.call(any)).thenAnswer(
            (_) async => [const UseCaseResult.success(none)],
          );
          when(areLocalNotificationsAllowedUseCase.singleOutput(any))
              .thenAnswer((_) async => false);
          when(remoteNotificationsService.enableNotifications())
              .thenAnswer((_) async => false);
        },
        build: () => handlePushNotificationsCardClickedUseCase,
        input: [none],
        verify: (_) {
          verify(localNotificationsService.openNotificationsPage()).called(1);
          verifyNever(remoteNotificationsService.enableNotifications());
          verifyNever(savePushNotificationsStatusUseCase.call(none));
        },
        expect: [
          useCaseSuccess(false),
        ],
      );
    },
  );
}
