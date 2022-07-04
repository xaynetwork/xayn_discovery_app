import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';

abstract class PaymentService {
  Stream<PurchaserInfo> get purchaserInfoStream;

  Future<List<Package>> getPackages();

  Future<PurchaserInfo> purchaseProduct(
    PurchasableProductId id, {
    UpgradeInfo? upgradeInfo,
    PurchaseType type = PurchaseType.subs,
  });

  Future<PurchaserInfo> restore();

  Future<PurchaserInfo> getPurchaserInfo();

  Future<void> presentCodeRedemptionSheet();

  Future<String?> get subscriptionManagementURL;

  Future<void> setAppsFlyerID(String appsFlyerId);
}
