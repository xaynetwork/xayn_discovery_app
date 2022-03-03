import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';

extension PurchaserInfoExtension on PurchaserInfo {
  bool getWillRenew(PurchasableProductId param) {
    final entitlement = entitlements.active[param];
    return entitlement?.willRenew ?? false;
  }

  DateTime? getExpirationDate(PurchasableProductId param) {
    final entitlement = entitlements.active[param];
    final expirationDateString = entitlement?.expirationDate;
    return expirationDateString != null
        ? DateTime.parse(expirationDateString)
        : null;
  }
}
