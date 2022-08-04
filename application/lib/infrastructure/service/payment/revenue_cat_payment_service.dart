import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/env/env.dart';
import 'package:xayn_discovery_app/infrastructure/service/payment/payment_service.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

/// This class is just a proxy for [Purchases].
/// I created it, in order to be able to mock the behaviour in the useCases.
/// Unfortunately right now there is an issue with Mockito package we are using:
/// it is not supporting code generation for the methods that return generics.
/// In current case it is [InAppPurchase.getPlatformAddition]
/// which we are not using so far.
/// The issue described here: https://github.com/dart-lang/mockito/issues/338
@lazySingleton
class RevenueCatPaymentService implements PaymentService {
  /// This class is the only one place where we use [Purchases].

  final StreamController<CustomerInfo> _controller =
      StreamController<CustomerInfo>.broadcast();

  /// A stream of [CustomerInfo] objects. Emits when subscription state changes.
  @override
  Stream<CustomerInfo> get customerInfoStream => _controller.stream;

  RevenueCatPaymentService(AppStatusRepository appStatusRepository) {
    _init(userId: appStatusRepository.appStatus.userId.value);
  }

  void _init({required String userId}) async {
    Purchases.setDebugLogsEnabled(!EnvironmentHelper.kIsProductionFlavor);
    await Purchases.configure(PurchasesConfiguration(Platform.isIOS
        ? Env.revenueCatSdkKeyIos
        : Env.revenueCatSdkKeyAndroid));
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _controller.sink.add(customerInfo);
    });
    try {
      Purchases.logIn(userId);
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Future<List<Package>> getPackages() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? [];
  }

  @override
  Future<CustomerInfo> purchaseProduct(
    PurchasableProductId id, {
    UpgradeInfo? upgradeInfo,
    PurchaseType type = PurchaseType.subs,
  }) =>
      Purchases.purchaseProduct(
        id,
        upgradeInfo: upgradeInfo,
        type: type,
      );

  @override
  Future<CustomerInfo> restore() => Purchases.restorePurchases();

  @override
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  @override
  Future<void> setAppsFlyerID(String appsFlyerId) =>
      Purchases.setAppsflyerID(appsFlyerId);

  /// iOS only. Presents a code redemption sheet, useful for redeeming offer codes
  /// Refer to https://docs.revenuecat.com/docs/ios-subscription-offers#offer-codes for more information on how
  /// to configure and use offer codes
  @override
  Future<void> presentCodeRedemptionSheet() =>
      Purchases.presentCodeRedemptionSheet();

  @override
  Future<String?> get subscriptionManagementURL async {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.managementURL;
  }
}
