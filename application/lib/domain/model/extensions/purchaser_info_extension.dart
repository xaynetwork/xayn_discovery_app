import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/presentation/constants/entitlement_ids.dart';

extension PurchaserInfoExtension on PurchaserInfo {
  bool get willRenew {
    final entitlement = entitlements.active[EntitlementIds.unlimited];
    return entitlement?.willRenew ?? false;
  }

  DateTime? get expirationDate {
    final entitlement = entitlements.active[EntitlementIds.unlimited];
    return DateTime.tryParse(entitlement?.expirationDate ?? '');
  }
}
