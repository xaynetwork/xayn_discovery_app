import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_manager.dart';
import 'package:xayn_discovery_app/presentation/app/manager/app_state.dart';
import 'package:xayn_discovery_app/presentation/constants/purchasable_ids.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockListenAppThemeUseCase listenAppThemeUseCase;
  late MockIncrementAppSessionUseCase incrementAppSessionUseCase;
  late MockCreateOrGetDefaultCollectionUseCase
      createOrGetDefaultCollectionUseCase;
  late MockAppSettingsRepository appSettingsRepository;
  late MockRenameDefaultCollectionUseCase renameDefaultCollectionUseCase;
  late MockSetInitialIdentityParamsUseCase setInitialIdentityParamsUseCase;
  late MockSetIdentityParamUseCase setIdentityParamUseCase;
  late MockGetSubscriptionStatusUseCase getSubscriptionStatusUseCase;
  late MockListenSubscriptionStatusUseCase listenSubscriptionStatusUseCase;
  late MockSetCollectionAndBookmarksChangesIdentityParam
      setCollectionAndBookmarksChangesIdentityParam;

  late Collection mockDefaultCollection;
  final subscriptionStatus = SubscriptionStatus.initial();

  setUp(() {
    mockDefaultCollection =
        Collection.readLater(name: 'mock default collection');
    listenAppThemeUseCase = MockListenAppThemeUseCase();
    incrementAppSessionUseCase = MockIncrementAppSessionUseCase();
    createOrGetDefaultCollectionUseCase =
        MockCreateOrGetDefaultCollectionUseCase();
    renameDefaultCollectionUseCase = MockRenameDefaultCollectionUseCase();
    setInitialIdentityParamsUseCase = MockSetInitialIdentityParamsUseCase();
    setIdentityParamUseCase = MockSetIdentityParamUseCase();
    getSubscriptionStatusUseCase = MockGetSubscriptionStatusUseCase();
    listenSubscriptionStatusUseCase = MockListenSubscriptionStatusUseCase();
    setCollectionAndBookmarksChangesIdentityParam =
        MockSetCollectionAndBookmarksChangesIdentityParam();
    appSettingsRepository = MockAppSettingsRepository();

    when(appSettingsRepository.settings).thenReturn(AppSettings.initial());

    when(incrementAppSessionUseCase.call(none)).thenAnswer(
      (_) async => const [
        UseCaseResult.success(none),
      ],
    );
    when(listenAppThemeUseCase.transform(any)).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(createOrGetDefaultCollectionUseCase.call(any)).thenAnswer(
      (_) async => [
        UseCaseResult.success(mockDefaultCollection),
      ],
    );
    when(setInitialIdentityParamsUseCase.call(none)).thenAnswer(
      (_) async => const [UseCaseResult.success(none)],
    );
    when(setCollectionAndBookmarksChangesIdentityParam.call(none)).thenAnswer(
      (_) async => const [UseCaseResult.success(none)],
    );
    when(getSubscriptionStatusUseCase.singleOutput(PurchasableIds.subscription))
        .thenAnswer((_) async => subscriptionStatus);
    when(listenSubscriptionStatusUseCase.transaction(any))
        .thenAnswer((_) => Stream.value(subscriptionStatus));
    when(listenSubscriptionStatusUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);
    when(setIdentityParamUseCase.call(any)).thenAnswer(
      (_) async => const [UseCaseResult.success(none)],
    );
  });

  AppManager create() => AppManager(
        listenAppThemeUseCase,
        incrementAppSessionUseCase,
        createOrGetDefaultCollectionUseCase,
        renameDefaultCollectionUseCase,
        setInitialIdentityParamsUseCase,
        setIdentityParamUseCase,
        getSubscriptionStatusUseCase,
        listenSubscriptionStatusUseCase,
        setCollectionAndBookmarksChangesIdentityParam,
        appSettingsRepository,
      );

  blocTest<AppManager, AppState>(
    'GIVEN manager WHEN it is created THEN verify appTheme received',
    build: create,
    expect: () => const [
      AppState(
        appTheme: AppTheme.system,
        isAppPaused: false,
      )
    ],
    verify: (manager) {
      verifyInOrder([
        appSettingsRepository.settings,
        incrementAppSessionUseCase.call(none),
        createOrGetDefaultCollectionUseCase
            .call(R.strings.defaultCollectionNameReadLater),
        setInitialIdentityParamsUseCase.call(none),
        setIdentityParamUseCase.call(any),
        setIdentityParamUseCase.call(any),
      ]);
      verifyNoMoreInteractions(appSettingsRepository);
      verifyNoMoreInteractions(createOrGetDefaultCollectionUseCase);
      verifyNoMoreInteractions(setInitialIdentityParamsUseCase);
      verifyNoMoreInteractions(setIdentityParamUseCase);
      verifyNoMoreInteractions(incrementAppSessionUseCase);
    },
  );

  blocTest<AppManager, AppState>(
    'WHEN maybeUpdateDefaultCollectionName is called THEN call the useCase',
    build: create,
    act: (manager) => manager.maybeUpdateDefaultCollectionName(),
    verify: (manager) {
      verify(
        renameDefaultCollectionUseCase.call(
          R.strings.defaultCollectionNameReadLater,
        ),
      ).called(1);

      verifyNoMoreInteractions(renameDefaultCollectionUseCase);
    },
  );
}
