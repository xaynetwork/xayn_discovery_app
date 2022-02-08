import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/payment/payment_flow_error.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/payment/check_subscription_active_use_case.dart';

import '../../../presentation/test_utils/utils.dart';
import 'payment_test_data.dart';

void main() {
  late MockPaymentService paymentService;
  late MockAppleVerifyReceiptHelper verifyReceiptHelper;
  late CheckSubscriptionActiveUseCase useCaseAndroid;
  late CheckSubscriptionActiveUseCase useCaseIOs;
  const productId = 'productId';

  setUp(() {
    paymentService = MockPaymentService();
    verifyReceiptHelper = MockAppleVerifyReceiptHelper();
    when(paymentService.isAvailable()).thenAnswer((_) => Future.value(true));
    when(paymentService.restorePurchases()).thenAnswer((_) async => {});

    useCaseAndroid = CheckSubscriptionActiveUseCase.test(
      paymentService,
      verifyReceiptHelper,
      isIos: false,
    );
    useCaseIOs = CheckSubscriptionActiveUseCase.test(
      paymentService,
      verifyReceiptHelper,
      isIos: true,
    );
  });

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for android: WHEN paymentService not available THEN throw storeNotAvailable error',
    setUp: () {
      when(paymentService.isAvailable()).thenAnswer((_) async => false);
    },
    build: () => useCaseAndroid,
    input: {productId},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.storeNotAvailable)),
    ],
    verify: (_) {
      verify(paymentService.isAvailable());
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(verifyReceiptHelper);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for ios: WHEN paymentService not available THEN throw storeNotAvailable error',
    setUp: () {
      when(paymentService.isAvailable()).thenAnswer((_) async => false);
    },
    build: () => useCaseIOs,
    input: {productId},
    expect: [
      useCaseFailure(throwsA(PaymentFlowError.storeNotAvailable)),
    ],
    verify: (_) {
      verify(paymentService.isAvailable());
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(verifyReceiptHelper);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for android: GIVEN purchaseStream with empty list WHEN paymentService is available THEN call restorePurchase and yield false',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([]));
    },
    build: () => useCaseAndroid,
    input: {productId},
    expect: [useCaseSuccess(false)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(verifyReceiptHelper);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for ios: GIVEN purchaseStream with empty list WHEN paymentService is available THEN call restorePurchase and yield false',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([]));
    },
    build: () => useCaseIOs,
    input: {productId},
    expect: [useCaseSuccess(false)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(verifyReceiptHelper);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for android: GIVEN purchaseStream without desired productId WHEN paymentService is available THEN call restorePurchase and yield false',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
            createPurchase(PurchaseStatus.pending, id: 'another'),
          ]));
    },
    build: () => useCaseAndroid,
    input: {productId},
    expect: [useCaseSuccess(false)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(verifyReceiptHelper);
    },
  );

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for ios: GIVEN purchaseStream without desired productId WHEN paymentService is available THEN call restorePurchase and yield false',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
            createPurchase(PurchaseStatus.pending, id: 'another'),
          ]));
    },
    build: () => useCaseIOs,
    input: {productId},
    expect: [useCaseSuccess(false)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
      verifyZeroInteractions(verifyReceiptHelper);
    },
  );

  group(
      'GIVEN purchaseStream with desired productId but with non restored status',
      () {
    PurchaseStatus.values
        .where((element) => element != PurchaseStatus.restored)
        .forEach(
      (status) {
        useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
          'for android: GIVEN status $status WHEN paymentService is available THEN call restorePurchase and yield false',
          setUp: () {
            when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
                  createPurchase(PurchaseStatus.pending, id: productId),
                ]));
          },
          build: () => useCaseAndroid,
          input: {productId},
          expect: [useCaseSuccess(false)],
          verify: (_) {
            verifyInOrder([
              paymentService.isAvailable(),
              paymentService.restorePurchases(),
              paymentService.purchaseStream,
            ]);
            verifyNoMoreInteractions(paymentService);
            verifyZeroInteractions(verifyReceiptHelper);
          },
        );
        useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
          'for ios: GIVEN status $status WHEN paymentService is available THEN call restorePurchase and yield false',
          setUp: () {
            when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
                  createPurchase(PurchaseStatus.pending, id: productId),
                ]));
          },
          build: () => useCaseIOs,
          input: {productId},
          expect: [useCaseSuccess(false)],
          verify: (_) {
            verifyInOrder([
              paymentService.isAvailable(),
              paymentService.restorePurchases(),
              paymentService.purchaseStream,
            ]);
            verifyNoMoreInteractions(paymentService);
            verifyZeroInteractions(verifyReceiptHelper);
          },
        );
      },
    );
  });

  useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
    'for android: GIVEN ${PurchaseStatus.restored} WHEN paymentService is available THEN call restorePurchase and yield true',
    setUp: () {
      when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
            createPurchase(PurchaseStatus.restored, id: productId),
          ]));
    },
    build: () => useCaseAndroid,
    input: {productId},
    expect: [useCaseSuccess(true)],
    verify: (_) {
      verifyInOrder([
        paymentService.isAvailable(),
        paymentService.restorePurchases(),
        paymentService.purchaseStream,
      ]);
      verifyNoMoreInteractions(paymentService);
    },
  );

  group(
    'for ios: GIVEN ${PurchaseStatus.restored} WHEN paymentService is available',
    () {
      setUp(() {
        when(paymentService.purchaseStream).thenAnswer(
          (_) => Stream.value([
            createPurchase(PurchaseStatus.restored, id: productId),
          ]),
        );
        when(
          verifyReceiptHelper.getSubscriptionExpireDate(
            serverVerificationData: anyNamed('serverVerificationData'),
            credentials: anyNamed('credentials'),
          ),
        ).thenAnswer((_) async => DateTime.now());
      });
      useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
        'GIVEN list of purchases with pendingCompletePurchase == true THEN call completePurchase for all of them',
        setUp: () {
          when(paymentService.purchaseStream).thenAnswer((_) => Stream.value([
                createPurchase(
                  PurchaseStatus.restored,
                  id: productId,
                  pendingCompletePurchase: true,
                ),
                createPurchase(
                  PurchaseStatus.restored,
                  id: productId,
                  pendingCompletePurchase: true,
                ),
                createPurchase(
                  PurchaseStatus.restored,
                  id: productId,
                  pendingCompletePurchase: true,
                ),
              ]));
        },
        build: () => useCaseIOs,
        input: {productId},
        expect: [useCaseSuccess(false)],
        verify: (_) {
          verifyInOrder([
            paymentService.isAvailable(),
            paymentService.restorePurchases(),
            paymentService.purchaseStream,
            paymentService.completePurchase(any),
            paymentService.completePurchase(any),
            paymentService.completePurchase(any),
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: serverVerificationData,
              credentials: anyNamed('credentials'),
            ),
          ]);
          verifyNoMoreInteractions(paymentService);
          verifyNoMoreInteractions(verifyReceiptHelper);
        },
      );

      useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
        'GIVEN single purchase WHEN verifyReceiptHelper return dateTime > now THEN call restorePurchase and yield true',
        setUp: () {
          when(
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: anyNamed('serverVerificationData'),
              credentials: anyNamed('credentials'),
            ),
          ).thenAnswer(
            (_) async => DateTime.now().add(const Duration(seconds: 1)),
          );
        },
        build: () => useCaseIOs,
        input: {productId},
        expect: [useCaseSuccess(true)],
        verify: (_) {
          verifyInOrder([
            paymentService.isAvailable(),
            paymentService.restorePurchases(),
            paymentService.purchaseStream,
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: serverVerificationData,
              credentials: anyNamed('credentials'),
            ),
          ]);
          verifyNoMoreInteractions(paymentService);
          verifyNoMoreInteractions(verifyReceiptHelper);
        },
      );

      useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
        'GIVEN single purchase WHEN verifyReceiptHelper return dateTime == now THEN call restorePurchase and yield false',
        setUp: () {
          when(
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: anyNamed('serverVerificationData'),
              credentials: anyNamed('credentials'),
            ),
          ).thenAnswer((_) async => DateTime.now());
        },
        build: () => useCaseIOs,
        input: {productId},
        expect: [useCaseSuccess(false)],
        verify: (_) {
          verifyInOrder([
            paymentService.isAvailable(),
            paymentService.restorePurchases(),
            paymentService.purchaseStream,
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: serverVerificationData,
              credentials: anyNamed('credentials'),
            ),
          ]);
          verifyNoMoreInteractions(paymentService);
          verifyNoMoreInteractions(verifyReceiptHelper);
        },
      );

      useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
        'GIVEN single purchase WHEN verifyReceiptHelper return dateTime < now THEN call restorePurchase and yield false',
        setUp: () {
          when(
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: anyNamed('serverVerificationData'),
              credentials: anyNamed('credentials'),
            ),
          ).thenAnswer(
            (_) async => DateTime.now().subtract(const Duration(seconds: 1)),
          );
        },
        build: () => useCaseIOs,
        input: {productId},
        expect: [useCaseSuccess(false)],
        verify: (_) {
          verifyInOrder([
            paymentService.isAvailable(),
            paymentService.restorePurchases(),
            paymentService.purchaseStream,
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: serverVerificationData,
              credentials: anyNamed('credentials'),
            ),
          ]);
          verifyNoMoreInteractions(paymentService);
          verifyNoMoreInteractions(verifyReceiptHelper);
        },
      );

      useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
        'GIVEN single purchase WHEN verifyReceiptHelper return null THEN call restorePurchase and yield false',
        setUp: () {
          when(
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: anyNamed('serverVerificationData'),
              credentials: anyNamed('credentials'),
            ),
          ).thenAnswer((_) async => null);
        },
        build: () => useCaseIOs,
        input: {productId},
        expect: [useCaseSuccess(false)],
        verify: (_) {
          verifyInOrder([
            paymentService.isAvailable(),
            paymentService.restorePurchases(),
            paymentService.purchaseStream,
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: serverVerificationData,
              credentials: anyNamed('credentials'),
            ),
          ]);
          verifyNoMoreInteractions(paymentService);
          verifyNoMoreInteractions(verifyReceiptHelper);
        },
      );

      useCaseTest<CheckSubscriptionActiveUseCase, PurchasableProductId, bool>(
        'GIVEN single purchase WHEN verifyReceiptHelper throw PaymentFlowError THEN reThrow that error',
        setUp: () {
          when(
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: anyNamed('serverVerificationData'),
              credentials: anyNamed('credentials'),
            ),
          ).thenAnswer(
            (_) async => throw PaymentFlowError.checkSubscriptionActiveFailed,
          );
        },
        build: () => useCaseIOs,
        input: {productId},
        expect: [
          useCaseFailure(
            throwsA(PaymentFlowError.checkSubscriptionActiveFailed),
          )
        ],
        verify: (_) {
          verifyInOrder([
            paymentService.isAvailable(),
            paymentService.restorePurchases(),
            paymentService.purchaseStream,
            verifyReceiptHelper.getSubscriptionExpireDate(
              serverVerificationData: serverVerificationData,
              credentials: anyNamed('credentials'),
            ),
          ]);
          verifyNoMoreInteractions(paymentService);
          verifyNoMoreInteractions(verifyReceiptHelper);
        },
      );
    },
  );
}
