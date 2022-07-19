import 'dart:math';

import 'package:purchases_flutter/models/entitlement_info_wrapper.dart';
import 'package:purchases_flutter/models/entitlement_infos_wrapper.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/product_wrapper.dart';
import 'package:purchases_flutter/models/purchaser_info_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/presentation/constants/entitlement_ids.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

class PaymentMockData {
  PaymentMockData._();

  static Duration get requestSimulationDuration => EnvironmentHelper.kIsInTest
      ? const Duration()
      : Duration(seconds: Random().nextInt(3));

  static const productId = 'product_id';

  static const product = Product(
    productId,
    'Access to all features (Mock)',
    'Xayn Unlimited (Mock)',
    0.0,
    '9.99 €',
    'EUR',
  );

  static const package = Package(
    'package_id',
    PackageType.monthly,
    PaymentMockData.product,
    'offering_id',
  );

  static const purchasableProduct = PurchasableProduct(
    id: productId,
    title: 't',
    description: 'd',
    price: 'p',
    currency: 'usd',
    duration: 'month',
    status: PurchasableProductStatus.purchasable,
  );

  static PurchaserInfo createPurchaserInfo({
    bool withActiveSubscription = true,
    bool willRenew = false,
  }) {
    const subscriptionId = productId;
    const entitlementId = EntitlementIds.unlimited;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final isActive = withActiveSubscription;
    final entitlementInfo = EntitlementInfo(
      entitlementId,
      isActive,
      willRenew,
      '',
      '',
      subscriptionId,
      true,
      expirationDate:
          withActiveSubscription ? tomorrow.toIso8601String() : null,
    );
    final entitlements = EntitlementInfos(
      {entitlementId: entitlementInfo},
      {entitlementId: entitlementInfo},
    );
    return PurchaserInfo(
      withActiveSubscription ? entitlements : const EntitlementInfos({}, {}),
      {},
      withActiveSubscription ? [entitlementId] : [],
      [],
      [],
      '',
      '',
      {},
      '',
      latestExpirationDate:
          withActiveSubscription ? tomorrow.toIso8601String() : null,
    );
  }
}
