import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';

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

  Future<PurchaserInfo> getPurchaserInfo() => Purchases.getPurchaserInfo();
}
