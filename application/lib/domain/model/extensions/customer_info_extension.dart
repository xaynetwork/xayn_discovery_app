import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/presentation/constants/entitlement_ids.dart';

extension CustomerInfoExtension on CustomerInfo {
  bool get willRenew {
    final entitlement = entitlements.active[EntitlementIds.unlimited];
    return entitlement?.willRenew ?? false;
  }

  DateTime? get expirationDate {
    final entitlement = entitlements.active[EntitlementIds.unlimited];
    return DateTime.tryParse(entitlement?.expirationDate ?? '');
  }

  DateTime? get purchaseDate => DateTime.tryParse(originalPurchaseDate ?? '');
}
