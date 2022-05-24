import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_mock_data.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';

/// This is a fake [PaymentService] used for non-release builds in order
/// to test UI related code.
@lazySingleton
class FakePaymentService implements PaymentService {
  final StreamController<PurchaserInfo> _controller =
      StreamController<PurchaserInfo>.broadcast();

  @override
  Stream<PurchaserInfo> get purchaserInfoStream => _controller.stream;

  /// Allow to test the purchase flow for non-release builds.
  bool _hasMockActiveSubscription = false;

  FakePaymentService();

  @override
  Future<List<Package>> getPackages() => Future.delayed(
        PaymentMockData.requestSimulationDuration,
        () => [PaymentMockData.package],
      );

  @override
  Future<PurchaserInfo> purchaseProduct(
    PurchasableProductId id, {
    UpgradeInfo? upgradeInfo,
    PurchaseType type = PurchaseType.subs,
  }) {
    _hasMockActiveSubscription = true;
    return Future.delayed(
      PaymentMockData.requestSimulationDuration,
      () {
        final purchaserInfo = PaymentMockData.createPurchaserInfo(
            withActiveSubscription: _hasMockActiveSubscription);
        _controller.sink.add(purchaserInfo);
        return purchaserInfo;
      },
    );
  }

  @override
  Future<PurchaserInfo> restore() {
    _hasMockActiveSubscription = true;
    return Future.delayed(
      PaymentMockData.requestSimulationDuration,
      () {
        final purchaserInfo = PaymentMockData.createPurchaserInfo(
            withActiveSubscription: _hasMockActiveSubscription);
        _controller.sink.add(purchaserInfo);
        return purchaserInfo;
      },
    );
  }

  @override
  Future<PurchaserInfo> getPurchaserInfo() =>
      Future.value(PaymentMockData.createPurchaserInfo(
          withActiveSubscription: _hasMockActiveSubscription));

  @override
  Future<void> presentCodeRedemptionSheet() => Future.value();

  @override
  Future<String?> get subscriptionManagementURL =>
      Future.value(Constants.xaynUrl);
}
