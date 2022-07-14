import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';

abstract class PaymentService {
  Stream<CustomerInfo> get customerInfoStream;

  Future<List<Package>> getPackages();

  Future<CustomerInfo> purchaseProduct(
    PurchasableProductId id, {
    UpgradeInfo? upgradeInfo,
    PurchaseType type = PurchaseType.subs,
  });

  Future<CustomerInfo> restore();

  Future<CustomerInfo> getCustomerInfo();

  Future<void> presentCodeRedemptionSheet();

  Future<String?> get subscriptionManagementURL;

  Future<void> setAppsFlyerID(String appsFlyerId);
}
