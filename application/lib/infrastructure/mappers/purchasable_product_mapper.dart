import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:xayn_discovery_app/domain/model/extensions/package_type_extension.dart';
import 'package:xayn_discovery_app/domain/model/payment/purchasable_product.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@lazySingleton
class PurchasableProductMapper implements Mapper<Package, PurchasableProduct> {
  @override
  PurchasableProduct map(Package input) => PurchasableProduct(
        id: input.product.identifier,
        title: input.product.title,
        description: input.product.description,
        price: input.product.priceString,
        currency: input.product.currencyCode,
        duration: input.packageType.localizedString,
        status: PurchasableProductStatus.purchasable,
      );
}
