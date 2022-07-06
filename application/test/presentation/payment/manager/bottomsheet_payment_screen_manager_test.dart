import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/fake_payment_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/redeem_promo_code_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/payment/manager/payment_screen_state.dart';

import '../../../test_utils/matchers.dart';
import '../../../test_utils/widget_test_utils.dart';

void main() {
  setUp(() async {
    await setupWidgetTest();
  });

  bool bottomSheetDismissed = false;

  BottomSheetPaymentScreenManager manager(
      {bool altPromoCode = false,
      String platform = 'ios',
      bool zeroTrialTime = false}) {
    final featureManager = di.get<FeatureManager>();
    if (zeroTrialTime) {
      featureManager.setTrialDurationToZero();
    }
    bottomSheetDismissed = false;
    featureManager.overrideFeature(Feature.altPromoCode, altPromoCode);

    di.registerLazySingleton<PaymentService>(() => FakePaymentService());
    di.registerFactory<Platform>(() => FakePlatform(operatingSystem: platform));

    return di.get()
      ..dismissBottomSheet = () {
        bottomSheetDismissed = true;
      };
  }

  blocTest<BottomSheetPaymentScreenManager, PaymentScreenState>(
      'Startup state shows a product',
      build: manager,
      wait: const Duration(),
      expect: () => [
            withPurchasableProduct(allOf(
              hasProductTitle('Xayn Unlimited (Mock)'),
              hasProductStatus(PurchasableProductStatus.purchasable),
            )),
          ],
      verify: (m) {
        expect(bottomSheetDismissed, false);
      });

  blocTest<BottomSheetPaymentScreenManager, PaymentScreenState>(
      'When subscribing the product, the state should end up being purchased and we leave the bottom sheet.',
      build: manager,
      act: (m) async {
        await Future.delayed(const Duration(milliseconds: 100));
        m.subscribe();
      },
      wait: const Duration(),
      expect: () => [
            withPurchasableProduct(
              hasProductStatus(PurchasableProductStatus.purchasable),
            ),
            withPurchasableProduct(
              hasProductStatus(PurchasableProductStatus.purchasePending),
            ),
            withPurchasableProduct(
              hasProductStatus(PurchasableProductStatus.purchased),
            ),
          ],
      verify: (m) {
        expect(bottomSheetDismissed, true);
      });

  blocTest<BottomSheetPaymentScreenManager, PaymentScreenState>(
    'When restoring the product, the state should end up being purchased and we leave the bottom sheet.',
    build: manager,
    act: (m) async {
      await Future.delayed(const Duration(milliseconds: 100));
      m.restore();
    },
    wait: const Duration(milliseconds: 100),
    expect: () => [
      withPurchasableProduct(
        hasProductStatus(PurchasableProductStatus.purchasable),
      ),
      withPurchasableProduct(
        hasProductStatus(PurchasableProductStatus.restorePending),
      ),
      // should be restored but the manager changes this to purchased because we it is an available product
      withPurchasableProduct(
        hasProductStatus(PurchasableProductStatus.purchased),
      ),
    ],
    verify: (m) {
      expect(bottomSheetDismissed, true);
    },
  );

  blocTest<BottomSheetPaymentScreenManager, PaymentScreenState>(
    'When pressing redeem promo code, we should enter to the native promo code experience.',
    build: () {
      return manager();
    },
    act: (m) async {
      await Future.delayed(const Duration(milliseconds: 100));
      m.enterRedeemCode();
    },
    wait: const Duration(),
    verify: (m) {
      final service = (di.get<PaymentService>() as FakePaymentService);
      expect(service.calledPresentCodeRedemptionSheet, true);
    },
  );

  blocTest<BottomSheetPaymentScreenManager, PaymentScreenState>(
    'Alt RedeemCode: When pressing redeem promo code, nothing should happen, because this should be done by the hosting screen',
    build: () {
      return manager(altPromoCode: true);
    },
    act: (m) async {
      await Future.delayed(const Duration(milliseconds: 100));
      m.enterRedeemCode();
    },
    wait: const Duration(),
    verify: (m) {
      expect(bottomSheetDismissed, false);
      expect(m.state, isA<PaymentScreenStateReady>());
    },
  );

  blocTest<BottomSheetPaymentScreenManager, PaymentScreenState>(
    'When the free trial period wasn\'t active and now we activate it, close the bottom sheet',
    build: () => manager(zeroTrialTime: true),
    act: (m) async {
      await Future.delayed(const Duration(milliseconds: 100));
      final statusRepository = di.get<AppStatusRepository>();
      statusRepository.save(statusRepository.appStatus.copyWith(
          extraTrialEndDate: DateTime.now().add(const Duration(days: 1))));
    },
    wait: const Duration(),
    verify: (m) {
      expect(bottomSheetDismissed, true);
    },
  );
}

typedef RedeemPromoCodeBottomSheetBuilder = RedeemPromoCodeBottomSheet Function(
    BuildContext, dynamic);
