import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

/// This class is just a proxy for [Purchases].
/// I created it, in order to be able to mock the behaviour in the useCases.
/// Unfortunately right now there is an issue with Mockito package we are using:
/// it is not supporting code generation for the methods that return generics.
/// In current case it is [InAppPurchase.getPlatformAddition]
/// which we are not using so far.
/// The issue described here: https://github.com/dart-lang/mockito/issues/338
@lazySingleton
class PaymentService {
  /// This class is the only one place where we use [Purchases].

  final StreamController<PurchaserInfo> _controller =
      StreamController<PurchaserInfo>.broadcast();

  /// A stream of [PurchaserInfo] objects. Emits when subscription state changes.
  Stream<PurchaserInfo> get purchaserInfoStream => _controller.stream;

  PaymentService() {
    _init();
  }

  void _init() async {
    Purchases.setDebugLogsEnabled(!EnvironmentHelper.kIsProductionFlavor);
    await Purchases.setup(Env.revenueCatSdkKey);
    try {
      Purchases.logIn('testUser');
    } catch (_) {}
    Purchases.addPurchaserInfoUpdateListener((purchaserInfo) {
      _controller.sink.add(purchaserInfo);
    });
  }

  Future<List<Product>> getProducts(
    List<String> identifiers, {
    PurchaseType type = PurchaseType.subs,
  }) =>
      Purchases.getProducts(identifiers, type: type);

  Future<PurchaserInfo> purchaseProduct(
    PurchasableProductId id, {
    UpgradeInfo? upgradeInfo,
    PurchaseType type = PurchaseType.subs,
  }) =>
      Purchases.purchaseProduct(
        id,
        upgradeInfo: upgradeInfo,
        type: type,
      );

  Future<PurchaserInfo> restore() => Purchases.restoreTransactions();

  Future<PurchaserInfo> getPurchaserInfo() => Purchases.getPurchaserInfo();

  /// iOS only. Presents a code redemption sheet, useful for redeeming offer codes
  /// Refer to https://docs.revenuecat.com/docs/ios-subscription-offers#offer-codes for more information on how
  /// to configure and use offer codes
  Future<void> presentCodeRedemptionSheet() =>
      Purchases.presentCodeRedemptionSheet();
}
